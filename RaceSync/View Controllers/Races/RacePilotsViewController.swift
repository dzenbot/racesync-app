//
//  RacePilotsViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import EmptyDataSet_Swift
import RaceSyncAPI

class RacePilotsViewController: UIViewController, ViewJoinable, RaceTabbable {

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
        get { return tabBarController.isLoading }
        set { }
    }

    override var tabBarController: RaceTabBarController {
        return super.tabBarController as! RaceTabBarController
    }

    fileprivate var raceApi = RaceApi()
    fileprivate var userApi = UserApi()
    fileprivate var userViewModels = [UserViewModel]()

    fileprivate var emptyStateRaceRegisters = EmptyStateViewModel(.noRaceRegisters)
    fileprivate var didTapCell: Bool = false

    fileprivate var shouldShowResults: Bool {
        guard let results = race.results, results.count > 0 else { return false }
        guard let startDate = race.startDate else { return false }
        return race.isFinalized && startDate.isPassed
    }

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

        title = shouldShowResults ? "Results" : "Pilots"
        let itemTitle = shouldShowResults ? "Race Results" : "Racing Pilots"
        tabBarItem = UITabBarItem(title: itemTitle, image: UIImage(named: "icn_tabbar_roster"), selectedImage: nil)

        if race.isMyChapter {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: ButtonImg.edit, style: .done, target: self, action: #selector(didPressEditButton))
        }
    }

    fileprivate func populateData() {

        if shouldShowResults, let results = ResultEntryViewModel.combinedResults(from: race.results, for: race.trueScoringFormat) {
            userViewModels = UserViewModel.viewModelsFromResults(results)
        } else if let entries = race.entries {
            userViewModels = UserViewModel.viewModelsFromEntries(entries)
        }
    }

    func reloadContent() {
        populateData()
        tableView.reloadData()
    }

    fileprivate func reloadRaceView() {
        tabBarController.reloadRaceView()
    }

    // MARK: - Actions

    @objc func didPressEditButton() {
        let vc = RacePilotsPickerController(with: race, raceId: tabBarController.raceId)
        vc.externalUserViewModels = userViewModels
        vc.delegate = self

        let nc = NavigationController(rootViewController: vc)
        present(nc, animated: true)
    }
}

fileprivate extension RacePilotsViewController {

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
        let viewModel = userViewModels[indexPath.row]
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

extension RacePilotsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showUserProfile(forUserAt: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if shouldShowResults {
            if race.isGQ {
                return "GQ Results: \(ScoringFormat.fastest3Laps.title)"
            } else {
                return race.scoringFormat.title
            }
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard userViewModels.count > 0 else { return 0 }
        return UITableView.automaticDimension
    }
}

extension RacePilotsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userViewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return avatarTableViewCell(for: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UniversalConstants.cellHeight
    }

    func avatarTableViewCell(for indexPath: IndexPath) -> AvatarTableViewCell {
        let viewModel = userViewModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as AvatarTableViewCell

        cell.avatarImageView.imageView.setImage(with: viewModel.pictureUrl, placeholderImage: PlaceholderImg.medium)
        cell.titleLabel.text = viewModel.displayName

        if shouldShowResults, let resultEntry = viewModel.resultEntry {
            let resultViewModel = ResultEntryViewModel(with: resultEntry, from: race)
            cell.subtitleLabel.text = resultViewModel.resultLabel
            cell.rankLabel.text = ResultEntryViewModel.rankLabel(for: indexPath.row+1)
            cell.rankLabel.isHidden = false
        } else {
            // TODO: Replace with something more useful? like location, race counts, or even a custom message when joining the race!
            cell.subtitleLabel.text = ResultEntryViewModel.noResultPlaceholder
            cell.rankLabel.isHidden = true
        }

        return cell
    }
}

extension RacePilotsViewController: RacePilotsPickerControllerDelegate {

    func pickerControllerDidUpdate(_ viewController: RacePilotsPickerController) {
        reloadRaceView()
    }
}

extension RacePilotsViewController: EmptyDataSetSource {

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

extension RacePilotsViewController: EmptyDataSetDelegate {

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
