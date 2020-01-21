//
//  RaceDetailViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift
import RaceSyncAPI

class RaceDetailViewController: UIViewController, Joinable {

    // MARK: - Private Variables

    fileprivate var isLoading: Bool {
        get {
            guard let tabBarController = tabBarController as? RaceTabBarController else { return false }
            return tabBarController.isLoading
        }
        set { }
    }

    fileprivate let headerView = RaceHeaderView()

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Color.gray50
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        return tableView
    }()

    fileprivate var raceApi = RaceApi()
    fileprivate var userApi = UserApi()
    fileprivate var race: Race
    fileprivate var myRaceEntry: RaceEntry?
    fileprivate var isRacing: Bool { return myRaceEntry != nil }
    fileprivate var commonUserViewModels = [UserViewModel]()
    fileprivate var otherUserViewModels = [UserViewModel]()

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

        title = "Race Details"
        tabBarItem = UITabBarItem(title: "Race", image: UIImage(named: "icn_tab_race"), tag: 1)

        view.backgroundColor = Color.white

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    fileprivate func populateData() {
        guard let myUser = APIServices.shared.myUser else { return }

        myRaceEntry = race.entries?.filter({ (raceEntry) -> Bool in
            return raceEntry.pilotId == myUser.id
            }).first

        if let myRaceEntry = myRaceEntry, !myRaceEntry.frequency.isEmpty {
            if let commonRaceEntries = race.entries?.filter({ (raceEntry) -> Bool in
                return myRaceEntry.frequency == raceEntry.frequency && myRaceEntry.pilotId != raceEntry.pilotId
            }) {
                commonUserViewModels = UserViewModel.viewModels(with: commonRaceEntries)
            }
            if let otherRaceEntries = race.entries?.filter({ (raceEntry) -> Bool in
                return myRaceEntry.frequency != raceEntry.frequency && myRaceEntry.pilotId != raceEntry.pilotId
            }) {
                otherUserViewModels = UserViewModel.viewModels(with: otherRaceEntries)
            }

            headerView.viewModel = RaceEntryViewModel(with: myRaceEntry)
            tableView.tableHeaderView = headerView

        } else if let allRaceEntries = race.entries {
            otherUserViewModels = UserViewModel.viewModels(with: allRaceEntries)
        }

        tableView.reloadData()
    }
}

extension RaceDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = userViewModel(at: indexPath)

        userApi.searchUser(with: viewModel.username) { (user, error) in
            if let user = user {
                let userVC = UserViewController(with: user)
                self.navigationController?.pushViewController(userVC, animated: true)
            } else if let _ = error {
                // handle error
            }
        }

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

extension RaceDetailViewController: UITableViewDataSource {

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
        let viewModel = userViewModel(at: indexPath)
        return userTableViewCell(for: viewModel)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UserTableViewCell.height
    }

    func userTableViewCell(for viewModel: UserViewModel) -> UserTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier) as! UserTableViewCell
        cell.titleLabel.text = viewModel.pilotName
        cell.avatarImageView.imageView.setImage(with: viewModel.pictureUrl, placeholderImage: UIImage(named: "placeholder_medium"))
        cell.subtitleLabel.text = viewModel.displayName

        if let raceEntry = viewModel.raceEntry {
            cell.channelBadge.titleLabel.text = RaceEntryViewModel.shortChannelLabel(for: raceEntry)
            cell.channelBadge.backgroundColor = RaceEntryViewModel.backgroundColor(for: raceEntry)
            cell.channelBadge.isHidden = false
        } else {
            cell.channelBadge.isHidden = true
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

extension RaceDetailViewController: EmptyDataSetSource {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        emptyStateRaceRegisters.title
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return emptyStateRaceRegisters.description
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        emptyStateRaceRegisters.buttonTitle(state)
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView) -> UIColor? {
        return Color.white
    }
}

extension RaceDetailViewController: EmptyDataSetDelegate {

    func emptyDataSetShouldDisplay(_ scrollView: UIScrollView) -> Bool {
        return !isLoading
    }

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return false
    }

    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {

        let currentState: JoinState = .join

        join(race: race, raceApi: raceApi) { [weak self] (newState) in
            if let tabBarController = self?.tabBarController as? RaceTabBarController, currentState != newState {
                tabBarController.reloadAllTabs()
                self?.tableView.reloadEmptyDataSet()
            }
        }
    }
}
