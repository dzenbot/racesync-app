//
//  RaceRosterViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift
import RaceSyncAPI

class RaceRosterViewController: UIViewController, ViewJoinable, RaceTabbable {

    // MARK: - Public Variables

    var race: Race

    // MARK: - Private Variables

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Color.gray50
        tableView.register(cellType: AvatarTableViewCell.self)
        return tableView
    }()

    fileprivate var isLoading: Bool {
        get {
            guard let tabBarController = tabBarController as? RaceTabBarController else { return false }
            return tabBarController.isLoading
        }
        set { }
    }

    fileprivate let headerView = RaceHeaderView()
    fileprivate var didTapCell: Bool = false

    fileprivate var raceApi = RaceApi()
    fileprivate var userApi = UserApi()
    fileprivate var myRaceEntry: RaceEntry?
    fileprivate var isRacing: Bool { return myRaceEntry != nil }
    fileprivate var commonUserViewModels = [UserViewModel]()
    fileprivate var otherUserViewModels = [UserViewModel]()
    fileprivate var myUserViewModel: UserViewModel?

    fileprivate var raceUserViewModels: [UserViewModel] {
        get {
            var models = [UserViewModel]()

            if commonUserViewModels.count > 0 {
                models += commonUserViewModels
            }
            if otherUserViewModels.count > 0 {
                models += otherUserViewModels
            }
            if let model = myUserViewModel {
                models += [model]
            }
            return models
        }
        set { }
    }

    fileprivate var emptyStateRaceRegisters = EmptyStateViewModel(.noRaceRegisters)

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
    }

    // MARK: - Initialization

    init(with race: Race) {
        self.race = race

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        configureNavigationItems()
        populateData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        view.backgroundColor = Color.white

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    fileprivate func configureNavigationItems() {
        title = "Pilots"
        tabBarItem = UITabBarItem(title: self.title, image: UIImage(named: "icn_tabbar_roster"), selectedImage: UIImage(named: "icn_tabbar_roster_selected"))

        if race.isMyChapter {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: ButtonImg.edit, style: .done, target: self, action: #selector(didPressEditButton))
        }
    }

    fileprivate func populateData() {
        guard let myUser = APIServices.shared.myUser else { return }
        guard let entries = race.entries else { return }

        myRaceEntry = entries.filter({ (raceEntry) -> Bool in
            return raceEntry.pilotId == myUser.id && entries.count > 1
            }).first

        if let myRaceEntry = myRaceEntry, !myRaceEntry.frequency.isEmpty {

            let commonRaceEntries = entries.filter({ (raceEntry) -> Bool in
                return myRaceEntry.frequency == raceEntry.frequency && myRaceEntry.pilotId != raceEntry.pilotId
            })
            let otherRaceEntries = entries.filter({ (raceEntry) -> Bool in
                return myRaceEntry.frequency != raceEntry.frequency && myRaceEntry.pilotId != raceEntry.pilotId
            })

            commonUserViewModels = UserViewModel.viewModels(with: commonRaceEntries)
            otherUserViewModels = UserViewModel.viewModels(with: otherRaceEntries)
            myUserViewModel = UserViewModel(with: myRaceEntry)

            headerView.viewModel = RaceEntryViewModel(with: myRaceEntry)
            tableView.tableHeaderView = headerView

        } else {
            otherUserViewModels = UserViewModel.viewModels(with: entries)
        }
    }

    func reloadContent() {
        populateData()
        tableView.reloadData()
    }

    fileprivate func reloadRaceView() {
        guard let tabBarController = tabBarController as? RaceTabBarController else { return }
        tabBarController.reloadRaceView()
    }

    // MARK: - Actions

    @objc func didPressEditButton() {
        let vc = RacePilotsPickerController(with: race)
        vc.externalUserViewModels = raceUserViewModels
        vc.delegate = self

        let nc = NavigationController(rootViewController: vc)
        present(nc, animated: true)
    }
}

fileprivate extension RaceRosterViewController {

    func setLoading(_ cell: AvatarTableViewCell, loading: Bool) {
        cell.isLoading = loading
        didTapCell = loading
    }
    
    func canInteract(with cell: AvatarTableViewCell) -> Bool {
        guard !cell.isLoading else { return false }
        guard !didTapCell else { return false }
        return true
    }

    func showUserProfile(forUserAt indexPath: IndexPath) {
        let viewModel = userViewModel(at: indexPath)
        let cell = tableView.cellForRow(at: indexPath) as! AvatarTableViewCell

        guard canInteract(with: cell) else { return }
        setLoading(cell, loading: true)

        // needs to search for a User since we don't have its id
        userApi.searchUser(with: viewModel.username) { [weak self] (user, error) in
            if let user = user {
                let vc = UserViewController(with: user)
                self?.navigationController?.pushViewController(vc, animated: true)
            } else if let _ = error {
                // handle error
            }
            self?.setLoading(cell, loading: false)
        }
    }
}

extension RaceRosterViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showUserProfile(forUserAt: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard userViewModels(for: section).count > 0 else { return nil }

        if commonUserViewModels.count > 0 {
            if section == 0 { return "Pilots on your frequency" }
            if section == 1 { return "Other Registered Pilots" }
        }
        return "Registered Pilots"
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard userViewModels(for: section).count > 0 else { return 0 }
        return UITableView.automaticDimension
    }
}

extension RaceRosterViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 0
        if commonUserViewModels.count > 0 { sections += 1 }
        if otherUserViewModels.count > 0 { sections += 1 }
        return sections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userViewModels(for: section).count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return avatarTableViewCell(for: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UniversalConstants.cellHeight
    }

    func avatarTableViewCell(for indexPath: IndexPath) -> AvatarTableViewCell {
        let viewModel = userViewModel(at: indexPath)
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as AvatarTableViewCell
        cell.titleLabel.text = viewModel.pilotName
        cell.avatarImageView.imageView.setImage(with: viewModel.pictureUrl, placeholderImage: PlaceholderImg.medium)
        cell.subtitleLabel.text = viewModel.fullName

        if let raceEntry = viewModel.raceEntry {
            let title = RaceEntryViewModel.shortChannelLabel(for: raceEntry)

            cell.textBadge.isHidden = title.isEmpty
            cell.textBadge.titleLabel.text = title
            cell.textBadge.backgroundColor = RaceEntryViewModel.backgroundColor(for: raceEntry)
        } else {
            cell.textBadge.isHidden = true
        }

        return cell
    }

    func userViewModels(for section: Int) -> [UserViewModel] {
        if commonUserViewModels.count > 0 {
            if section == 0 { return commonUserViewModels }
            if section == 1 { return otherUserViewModels }
        }
        return otherUserViewModels
    }

    func userViewModel(at indexPath: IndexPath) -> UserViewModel {
        let viewModels = userViewModels(for: indexPath.section)
        return viewModels[indexPath.row]
    }
}

extension RaceRosterViewController: RacePilotsPickerControllerDelegate {

    func pickerControllerDidUpdate(_ viewController: RacePilotsPickerController) {
        reloadRaceView()
    }
}

extension RaceRosterViewController: EmptyDataSetSource {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        emptyStateRaceRegisters.title
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return emptyStateRaceRegisters.description
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        guard let startDate = race.startDate else { return nil }
        if race.status == .open && !startDate.isPassed {
            return emptyStateRaceRegisters.buttonTitle(state)
        } else {
            return nil
        }
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return Color.white
    }
}

extension RaceRosterViewController: EmptyDataSetDelegate {

    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return !isLoading
    }

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return false
    }

    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {

        let currentState: JoinState = .join

        join(race: race, raceApi: raceApi) { [weak self] (newState) in
            if currentState != newState {
                self?.reloadRaceView()
            }
        }
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -(view.safeAreaInsets.top + view.safeAreaInsets.bottom)
    }
}
