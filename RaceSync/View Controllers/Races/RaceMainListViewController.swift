//
//  RaceMainListViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-14.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI
import SnapKit
import ShimmerSwift
import EmptyDataSet_Swift
import CoreLocation

/**
 Main view of the application, displaying lists of races filtered by different toggles. This view is very specific to that use case.
 For a more generic display of races, use RaceListViewController.
 */
class RaceMainListViewController: UIViewController, ViewJoinable, Shimmable {

    // MARK: - Public Variables

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.register(cellType: RaceTableViewCell.self)
        tableView.refreshControl = self.refreshControl
        tableView.tableFooterView = UIView()
        tableView.contentInsetAdjustmentBehavior = .never

        for direction in [UISwipeGestureRecognizer.Direction.left, UISwipeGestureRecognizer.Direction.right] {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeHorizontally(_:)))
            gesture.direction = direction
            tableView.addGestureRecognizer(gesture)
        }

        return tableView
    }()

    var shimmeringView: ShimmeringView = defaultShimmeringView()

    // MARK: - Private Variables

    fileprivate lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.addTarget(self, action: #selector(didChangeSegment), for: .valueChanged)
        return segmentedControl
    }()

    fileprivate lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.white

        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(view.snp.top).offset(11)
            $0.leading.equalToSuperview().offset(Constants.padding)
            $0.trailing.equalToSuperview().offset(-Constants.padding)
            $0.bottom.equalTo(view.snp.bottom).offset(-11)
        }

        let separatorLine = UIView()
        separatorLine.backgroundColor = Color.gray100
        view.addSubview(separatorLine)
        separatorLine.snp.makeConstraints {
            $0.height.equalTo(0.5)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.snp.bottom)
        }
        return view
    }()

    fileprivate lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = Color.white
        refreshControl.tintColor = Color.blue
        refreshControl.addTarget(self, action: #selector(didPullRefreshControl), for: .valueChanged)
        return refreshControl
    }()

    fileprivate lazy var titleView: UIView = {
        let view = UIView()
        let imageView = UIImageView(image: UIImage(named: "racesync_logo_header"))
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.snp.top).offset(4)
        }
        return view
    }()

    fileprivate lazy var settingsButton: CustomButton = {
        let button = CustomButton(type: .system)
        button.addTarget(self, action: #selector(didPressSettingsButton), for: .touchUpInside)
        button.setImage(ButtonImg.settings, for: .normal)
        return button
    }()

    fileprivate lazy var searchButton: CustomButton = {
        let button = CustomButton(type: .system)
        button.addTarget(self, action: #selector(didPressSearchButton), for: .touchUpInside)
        button.setImage(ButtonImg.search, for: .normal)
        return button
    }()

    fileprivate lazy var userProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didPressUserProfileButton), for: .touchUpInside)
        button.isHidden = true

        if let placeholder = PlaceholderImg.small?.withRenderingMode(.alwaysOriginal) {
            button.setImage(placeholder, for: .normal) // 32x32
            button.layer.cornerRadius = placeholder.size.width / 2
            button.layer.borderWidth = 0.5
            button.layer.borderColor = Color.gray100.cgColor
            button.layer.masksToBounds = true
        }
        return button
    }()

    fileprivate lazy var chapterProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didPressChapterProfileButton), for: .touchUpInside)
        button.isHidden = true

        if let placeholder = PlaceholderImg.small?.withRenderingMode(.alwaysOriginal) {
            button.setImage(placeholder, for: .normal) // 32x32
            button.layer.cornerRadius = placeholder.size.width / 2
            button.layer.borderWidth = 0.5
            button.layer.borderColor = Color.gray100.cgColor
            button.layer.masksToBounds = true
        }
        return button
    }()

    fileprivate lazy var filterButton: CustomButton = {
        let button = CustomButton(type: .system)
        button.addTarget(self, action: #selector(didPressFilterButton), for: .touchUpInside)
        button.setTitle("Adjust Radius", for: .normal)
        button.setTitleColor(Color.red, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 19)
        return button
    }()

    fileprivate lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.navigationBarColor
        view.isHidden = true

        let separatorLine = UIView()
        separatorLine.backgroundColor = Color.gray100
        view.addSubview(separatorLine)
        separatorLine.snp.makeConstraints {
            $0.height.equalTo(0.25)
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.snp.top)
        }

        return view
    }()

    fileprivate var selectedRaceList: RaceFilter {
        get {
            let title: String = segmentedControl.titleForSelectedSegment()!
            return RaceFilter(title: title)!
        }
    }

    fileprivate let raceListController: RaceMainListController
    fileprivate let raceApi = RaceApi()
    fileprivate let userApi = UserApi()
    fileprivate let chapterApi = ChapterApi()
    fileprivate var raceList = [RaceViewModel]()
    fileprivate var settingsController = SettingsController()
    fileprivate let isUniversalSearchEnabled: Bool = false

    fileprivate var emptyStateJoinedRaces = EmptyStateViewModel(.noJoinedRaces)
    fileprivate var emptyStateChapterRaces = EmptyStateViewModel(.noJoinedRaces)
    fileprivate var emptyStateNearbyRaces = EmptyStateViewModel(.noNearbydRaces)
    fileprivate var emptyStateSeriesRaces = EmptyStateViewModel(.noSeriesRaces)

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let headerHeight: CGFloat = 50
        static let buttonSpacing: CGFloat = 12
        static let miniProfileSize: CGSize = CGSize(width: 32, height: 32)
        static let bottomViewHeight: CGFloat = 83
    }

    // MARK: - Initialization

    init(_ filters: [RaceFilter], selectedFilter: RaceFilter) {
        self.raceListController = RaceMainListController(filters)

        super.init(nibName: nil, bundle: nil)

        let idx = filters.firstIndex(of: selectedFilter)
        self.segmentedControl.setItems(filters.compactMap { $0.title })
        self.segmentedControl.selectedSegmentIndex = idx ?? 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()

        APIServices.shared.settings.add(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadContent()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        title = "Race List"
        navigationItem.titleView = titleView

        var leftStackSubviews = [settingsButton]
        if isUniversalSearchEnabled {
            leftStackSubviews += [searchButton]
        }

        let leftStackView = UIStackView(arrangedSubviews: leftStackSubviews)
        leftStackView.axis = .horizontal
        leftStackView.distribution = .fillEqually
        leftStackView.alignment = .leading
        leftStackView.spacing = Constants.padding
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftStackView)

        let rightStackView = UIStackView(arrangedSubviews: [chapterProfileButton, userProfileButton])
        rightStackView.axis = .horizontal
        rightStackView.distribution = .fillEqually
        rightStackView.alignment = .trailing
        rightStackView.spacing = Constants.buttonSpacing
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightStackView)

        view.addSubview(headerView)
        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(Constants.headerHeight)
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.snp.bottom)
        }

        view.addSubview(shimmeringView)
        shimmeringView.snp.makeConstraints {
            $0.top.equalTo(tableView.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(tableView.snp.bottom)
        }

        view.addSubview(bottomView)
        bottomView.snp.makeConstraints {
            $0.height.equalTo(Constants.bottomViewHeight)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        bottomView.addSubview(filterButton)
        filterButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomView.safeAreaLayoutGuide.snp.bottom)
        }
    }

    // MARK: - Actions

    @objc fileprivate func didChangeSegment() {
        // Cancelling previous race API requests to avoid overlaps
        raceApi.cancelAll()

        // This should be triggered just once, when first requesting access to the user's location
        // and display the shimmer while retrieving the location and loading the nearby races.
        let locationManager = LocationManager.shared
        if selectedRaceList == .nearby, !locationManager.didRequestAuthorization {
            isLoading(true)
            locationManager.requestsAuthorization { [weak self] (error) in
                self?.loadRaces()
            }
        } else {
            loadRaces()
        }

        toggleBottomView()
    }

    @objc fileprivate func didPressUserProfileButton() {
        guard let myUser = APIServices.shared.myUser else { return }

        let vc = UserViewController(with: myUser)
        let nc = NavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true)
    }

    @objc fileprivate func didPressChapterProfileButton() {
        guard let myChapter = APIServices.shared.myChapter else { return }

        let vc = ChapterViewController(with: myChapter)
        let nc = NavigationController(rootViewController: vc)
        nc.modalPresentationStyle = .fullScreen
        present(nc, animated: true)
    }

    @objc fileprivate func didPressSettingsButton(_ sender: Any) {
        let vc = SettingsViewController()
        let nc = NavigationController(rootViewController: vc)
        present(nc, animated: true)
    }

    @objc fileprivate func didPressSearchButton(_ sender: Any) {
        Clog.log("didPressSearchButton")
    }

    @objc fileprivate func didPressFilterButton(_ sender: Any) {
        settingsController.presentSettingsPicker(.searchRadius, from: self) {
            // event handled by the APISettingsDelegate implementation
        }
    }

    @objc fileprivate func didPressJoinButton(_ sender: JoinButton) {
        guard let objectId = sender.objectId, let race = raceList.race(withId: objectId) else { return }
        let joinState = sender.joinState

        toggleJoinButton(sender, forRace: race, raceApi: raceApi) { [weak self] (newState) in
            if joinState != newState {
                // reload races to reflect race changes, specially join counts
                self?.loadRaces(forceReload: true)
            }
        }
    }

    @objc fileprivate func didPressShowPastSeriesButton(_ sender: Any) {
        raceListController.showPastSeries = true
        loadRaces(forceReload: true)
    }

    @objc fileprivate func didPullRefreshControl() {
        loadRaces(forceReload: true)
    }

    fileprivate func openRaceDetail(_ viewModel: RaceViewModel) {
        let vc = RaceTabBarController(with: viewModel.race.id)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc fileprivate func didSwipeHorizontally(_ sender: Any) {
        guard let swipeGesture = sender as? UISwipeGestureRecognizer else { return }

        var newIndex = segmentedControl.selectedSegmentIndex

        if swipeGesture.direction == .left {
            newIndex += 1
        } else if swipeGesture.direction == .right {
            newIndex -= 1
        }

        guard newIndex >= 0 && newIndex <= segmentedControl.numberOfSegments else { return }
        segmentedControl.setSelectedSegment(newIndex)
    }

    fileprivate func selectSegment(_ filter: RaceFilter) {

        let idx = raceListController.raceFilters.firstIndex(of: filter) ?? 0
        segmentedControl.setSelectedSegment(idx)
    }
}

fileprivate extension RaceMainListViewController {

    func loadContent() {
        if APIServices.shared.myUser == nil {
            isLoading(true)
            loadMyUser()
        } else {
            loadRaces(forceReload: true)
        }
    }

    func loadMyUser() {
        userApi.getMyUser { [weak self] (user, error) in
            if let user = user {
                CrashCatcher.setupUser(user.id, username: user.userName)

                self?.updateUserProfileImage()
                self?.loadRaces()
            } else if error != nil {
                // This is somewhat the best way to detect an invalid session
                ApplicationControl.shared.invalidateSession(forced: true)
            }
        }

        chapterApi.getMyManagedChapters { [weak self] (managedChapters, error) in
            APIServices.shared.myManagedChapters = managedChapters

            if let managedChapter = managedChapters?.first {
                self?.chapterApi.getChapter(with: managedChapter.id) { (chapter, error) in
                    APIServices.shared.myChapter = chapter
                    self?.updateChapterProfileImage()
                }
            }
        }
    }

    @objc func loadRaces(forceReload: Bool = false) {
        let selectedList = selectedRaceList

        if raceListController.shouldShowShimmer(for: selectedList) {
            isLoading(true)
        }

        raceListController.raceViewModels(for: selectedList, forceFetch: forceReload) { [weak self] (viewModels, error) in
            guard let strongSelf = self else { return }

            strongSelf.isLoading(false)

            if let viewModels = viewModels, selectedList == strongSelf.selectedRaceList {
                strongSelf.raceList = viewModels

                if strongSelf.refreshControl.isRefreshing {
                    strongSelf.refreshControl.endRefreshing()
                }

                strongSelf.tableView.reloadData()
                strongSelf.toggleBottomView()
            } else {
                print("getMyRaces error : \(error.debugDescription)")
            }
        }
    }

    func updateUserProfileImage() {
        let imageUrl = APIServices.shared.myUser?.miniProfilePictureUrl
        let placeholder = PlaceholderImg.small?.withRenderingMode(.alwaysOriginal)
        
        userProfileButton.isHidden = false
        userProfileButton.setImage(with: imageUrl, placeholderImage: placeholder, forState: .normal, size: Constants.miniProfileSize) { (image) in

            // We do this here, to be guaranteed a user profile's image
            DispatchQueue.main.async {
                ApplicationControl.shared.startWatchConnection()
            }
        }
    }

    func updateChapterProfileImage() {
        let imageUrl = APIServices.shared.myChapter?.miniProfilePictureUrl
        let placeholder = PlaceholderImg.small?.withRenderingMode(.alwaysOriginal)

        chapterProfileButton.isHidden = false
        chapterProfileButton.setImage(with: imageUrl, placeholderImage: placeholder, forState: .normal, size: Constants.miniProfileSize)
    }

    func toggleBottomView() {

        var contentInset = tableView.contentInset
        var scrollIndicatorInsets = tableView.verticalScrollIndicatorInsets

        let shouldHide = (selectedRaceList != .nearby)
        let value: CGFloat = Constants.bottomViewHeight

        contentInset.bottom = shouldHide ? 0 : value
        scrollIndicatorInsets.bottom = shouldHide ? 0 : value * 3/4

        tableView.contentInset = contentInset
        tableView.verticalScrollIndicatorInsets = scrollIndicatorInsets
        bottomView.isHidden = shouldHide
    }
}

extension RaceMainListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let viewModel = raceList[indexPath.row]
        openRaceDetail(viewModel)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return RaceTableViewCell.height
    }
}

extension RaceMainListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return raceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as RaceTableViewCell
        let viewModel = raceList[indexPath.row]

        cell.dateLabel.text = viewModel.startDateLabel //"Saturday Sept 14 @ 9:00 AM"
        cell.titleLabel.text = viewModel.titleLabel
        cell.joinButton.type = .race
        cell.joinButton.objectId = viewModel.race.id
        cell.joinButton.joinState = viewModel.joinState
        cell.joinButton.addTarget(self, action: #selector(didPressJoinButton), for: .touchUpInside)
        cell.memberBadgeView.count = viewModel.participantCount
        cell.avatarImageView.imageView.setImage(with: viewModel.imageUrl, placeholderImage: PlaceholderImg.medium)

        if selectedRaceList == .joined {
            cell.subtitleLabel.text = viewModel.locationLabel
        } else if selectedRaceList == .chapters || selectedRaceList == .series {
            cell.subtitleLabel.text = viewModel.chapterLabel
        } else {
            cell.subtitleLabel.text = viewModel.distanceLabel
        }

        return cell
    }
}

extension RaceMainListViewController: EmptyDataSetSource {

    func getEmptyStateViewModel() -> EmptyStateViewModel {
        switch selectedRaceList {
        case .joined:       return emptyStateJoinedRaces
        case .chapters:     return emptyStateChapterRaces
        case .nearby:       return emptyStateNearbyRaces
        case .series:       return emptyStateSeriesRaces
        }
    }

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return getEmptyStateViewModel().title
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return getEmptyStateViewModel().description
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return nil
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        return getEmptyStateViewModel().buttonTitle(state)
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -(navigationController?.navigationBar.frame.height ?? 0)
    }
}

extension RaceMainListViewController: APISettingsDelegate {

    func didUpdate(settings: APISettingsType, with value: Any) {
        guard selectedRaceList == .nearby else { return }

        if settings == .measurement {
            loadRaces()
        } else if settings == .searchRadius {
            isLoading(true)
            loadRaces(forceReload: true)
        }
    }
}

extension RaceMainListViewController: EmptyDataSetDelegate {

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }

    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {

        if selectedRaceList == .joined {
            selectSegment(.nearby)
        } else if selectedRaceList == .chapters {
            //
        } else if selectedRaceList == .nearby {
            didPressFilterButton(button)
        } else if selectedRaceList == .series {
            didPressShowPastSeriesButton(button)
        }
    }
}
