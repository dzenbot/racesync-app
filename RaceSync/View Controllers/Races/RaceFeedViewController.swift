//
//  RaceFeedViewController.swift
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
class RaceFeedViewController: UIViewController, ViewJoinable, Shimmable {

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

    fileprivate lazy var titleView: UIView = {
        let view = UIView()
        let imageView = UIImageView(image: UIImage(named: "racesync_logo_header"))
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
        return view
    }()

    fileprivate lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.navigationBarColor
        view.tintColor = Color.blue

        let spacing = 10

        view.addSubview(mapButton)
        mapButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(Constants.padding)
            $0.width.equalTo(30)
        }

        view.addSubview(filterButton)
        filterButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-Constants.padding)
            $0.width.equalTo(30)
        }

        view.addSubview(segmentedControl)
        segmentedControl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(spacing)
            $0.leading.equalTo(mapButton.snp.trailing).offset(spacing)
            $0.trailing.equalTo(filterButton.snp.leading).offset(-spacing)
            $0.bottom.equalToSuperview().offset(-spacing)
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

    fileprivate lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.addTarget(self, action: #selector(didChangeSegment), for: .valueChanged)
        return control
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

    fileprivate lazy var filterButton: CustomButton = {
        let button = CustomButton(type: .system)
        button.addTarget(self, action: #selector(didPressFilterButton), for: .touchUpInside)
        button.setImage(ButtonImg.filter, for: .normal)
        return button
    }()

    fileprivate lazy var mapButton: CustomButton = {
        let button = CustomButton(type: .system)
        button.addTarget(self, action: #selector(didPressMapButton), for: .touchUpInside)
        button.setImage(ButtonImg.map, for: .normal)
        button.isHidden = !isMapViewEnabled
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

    fileprivate lazy var chapterProfileButton: CustomButton = {
        let button = CustomButton(type: .system)
        button.addTarget(self, action: #selector(didPressChapterProfileButton), for: .touchUpInside)
        button.addTarget(self, action: #selector(didLongPressChapterProfileButton), for: .touchLong)
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

    fileprivate lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = Color.white
        refreshControl.tintColor = Color.blue
        refreshControl.addTarget(self, action: #selector(didPullRefreshControl), for: .valueChanged)
        return refreshControl
    }()

    fileprivate var selectedRaceFilter: RaceFilter {
        get {
            let title: String = segmentedControl.titleForSelectedSegment()!
            return RaceFilter(title: title)!
        }
    }

    fileprivate var raceFeed: [RaceViewModel]? {
        get {
            return raceFeedController.raceViewModels(for: selectedRaceFilter)
        }
    }

    fileprivate var raceFeedCount: Int {
        get {
            return raceFeedController.raceViewModelsCount(for: selectedRaceFilter)
        }
    }

    fileprivate let raceFeedController: RaceFeedController
    fileprivate let raceApi = RaceApi()
    fileprivate let userApi = UserApi()
    fileprivate let chapterApi = ChapterApi()

    fileprivate let presenter = Appearance.defaultPresenter()
    fileprivate var formNavigationController: NavigationController?

    fileprivate let hidesNavigationShadowAtRoot: Bool = true
    fileprivate let isSearchEnabled: Bool = false
    fileprivate let isMapViewEnabled: Bool = false

    fileprivate var emptyStateJoinedRaces = EmptyStateViewModel(.noJoinedRaces)
    fileprivate var emptyStateChapterRaces = EmptyStateViewModel(.noJoinedRaces)
    fileprivate var emptyStateNearbyRaces = EmptyStateViewModel(.noNearbydRaces)
    fileprivate var emptyStateSeriesRaces = EmptyStateViewModel(.noSeriesRaces)

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let buttonSpacing: CGFloat = 12
        static let miniProfileSize: CGSize = CGSize(width: 32, height: 32)
    }

    // MARK: - Initialization

    init(_ filters: [RaceFilter], selectedFilter: RaceFilter) {
        self.raceFeedController = RaceFeedController(filters)

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

        if hidesNavigationShadowAtRoot {
            hideNavigationShadow()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if let nc = navigationController, nc.viewControllers.count == 2 {
            if hidesNavigationShadowAtRoot {
                hideNavigationShadow(false)
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        title = "Race List"
        navigationItem.titleView = titleView

        if hidesNavigationShadowAtRoot {
            hideNavigationShadow()
        }

        var leftStackSubviews = [settingsButton]
        if isSearchEnabled {
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
    }

    func hideNavigationShadow(_ hide: Bool = true) {
        guard let nc = navigationController else { return }

        // By masking to bounds, the shadow of a navigation bar is no longer visible
        // This trick only works when the backgroud of view behind the navigation bar is the same color
        // It cannot be used for transitioning to more complicated views.
        nc.navigationBar.layer.masksToBounds = hide
    }

    // MARK: - Actions

    @objc fileprivate func didChangeSegment() {
        // Cancelling previous race API requests to avoid overlaps
        raceApi.cancelAll()

        // This should be triggered just once, when first requesting access to the user's location
        // and display the shimmer while retrieving the location and loading the nearby races.
        let locationManager = LocationManager.shared
        if selectedRaceFilter == .nearby, !locationManager.didRequestAuthorization {
            isLoadingList(true)
            locationManager.requestsAuthorization { [weak self] (error) in
                self?.loadRaces()
            }
        } else {
            loadRaces()
        }
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

    @objc fileprivate func didLongPressChapterProfileButton() {

        let vc = ChapterPickerViewController()
        vc.title = "Change Home Chapter"
        vc.delegate = self

        let nc = NavigationController(rootViewController: vc)
        customPresentViewController(presenter, viewController: nc, animated: true)
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
        let vc = RaceFeedMenuViewController()
        let nc = NavigationController(rootViewController: vc)

        customPresentViewController(presenter, viewController: nc, animated: true)
    }

    @objc fileprivate func didPressMapButton(_ sender: Any) {
        Clog.log("didPressMapButton")
    }

    @objc fileprivate func didPressJoinButton(_ sender: JoinButton) {
        guard let objectId = sender.objectId, let race = raceFeed?.race(withId: objectId) else { return }
        let joinState = sender.joinState

        toggleJoinButton(sender, forRace: race, raceApi: raceApi) { [weak self] (newState) in
            if joinState != newState {
                // reload races to reflect race changes, specially join counts
                self?.loadRaces(forceReload: true)
            }
        }
    }

    @objc fileprivate func didPullRefreshControl() {
        loadRaces(forceReload: true)
    }

    fileprivate func openRaceDetail(_ viewModel: RaceViewModel) {
        let vc = RaceTabBarController(with: viewModel.race.id, ownerName: viewModel.race.ownerUserName)
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

        let idx = raceFeedController.raceFilters.firstIndex(of: filter) ?? 0
        segmentedControl.setSelectedSegment(idx)
    }
}

fileprivate extension RaceFeedViewController {

    func loadContent() {
        if APIServices.shared.myUser == nil {
            isLoadingList(true)
            loadMyUser()
        } else {
            loadRaces(forceReload: true)
        }
    }

    func loadMyUser() {
        userApi.getMyUser { [weak self] (user, error) in
            if let user = user {
                self?.loadRaces()
                self?.loadMyHomeChapter(user.homeChapterId)
                self?.loadMyManagedChapters()
                self?.updateUserProfileImage()
            } else if error != nil {
                // This is somewhat the best way to detect an invalid session
                ApplicationControl.shared.invalidateSession(forced: false)
            }
        }
    }

    func loadMyHomeChapter(_ chapterId: String) {
        guard !chapterId.isEmpty else { return }

        chapterApi.getChapter(with: chapterId) { [weak self] (chapter, error) in
            guard let chapter = chapter else { return }
            self?.updateMyHomeChapter(with: chapter)
        }
    }

    func loadMyManagedChapters() {
        chapterApi.getMyManagedChapters { (managedChapters, error) in

            guard let chapters = managedChapters else {
                APIServices.shared.myManagedChapters = []
                return
            }

            // Remove duplicated managed chapters, if any, and sorting alphabetically
            let uniqueChapters = Dictionary(grouping: chapters, by: \.id)
                .compactMap { $0.value.first }
                .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

            APIServices.shared.myManagedChapters = uniqueChapters
        }
    }

    @objc func loadRaces(forceReload: Bool = false) {
        let selectedList = selectedRaceFilter

        if raceFeedController.shouldShowShimmer(for: selectedList) {
            isLoadingList(true)
        }

        raceFeedController.raceViewModels(for: selectedList, forceFetch: forceReload) { [weak self] (viewModels, error) in
            guard let strongSelf = self else { return }

            strongSelf.isLoadingList(false)

            if let _ = viewModels, selectedList == strongSelf.selectedRaceFilter {
                if strongSelf.refreshControl.isRefreshing {
                    strongSelf.refreshControl.endRefreshing()
                }

                strongSelf.tableView.reloadData()
            } else {
                print("getMyRaces error : \(error.debugDescription)")
            }
        }
    }

    @objc func unloadRaces() {
        raceFeedController.invalidateDataSource()
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

    func updateMyHomeChapter(with chapter: Chapter) {
        APIServices.shared.myChapter = chapter
        updateChapterProfileImage()
    }
}

extension RaceFeedViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let viewModel = raceFeed?[indexPath.row] {
            openRaceDetail(viewModel)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return RaceTableViewCell.height
    }
}

extension RaceFeedViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return raceFeedCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as RaceTableViewCell
        guard let viewModel = raceFeed?[indexPath.row] else { return cell }

        cell.dateLabel.text = viewModel.startDateLabel //"Saturday Sept 14 @ 9:00 AM"
        cell.titleLabel.text = viewModel.titleLabel
        cell.joinButton.type = .race
        cell.joinButton.objectId = viewModel.race.id
        cell.joinButton.joinState = viewModel.joinState
        cell.joinButton.addTarget(self, action: #selector(didPressJoinButton), for: .touchUpInside)
        cell.memberBadgeView.count = viewModel.participantCount
        cell.avatarImageView.imageView.setImage(with: viewModel.imageUrl, placeholderImage: PlaceholderImg.medium)

        if selectedRaceFilter == .joined {
            cell.subtitleLabel.text = viewModel.locationLabel
        } else if selectedRaceFilter == .chapters || selectedRaceFilter == .series {
            cell.subtitleLabel.text = viewModel.chapterLabel
        } else {
            cell.subtitleLabel.text = viewModel.distanceLabel
        }

        return cell
    }
}

extension RaceFeedViewController: ChapterPickerViewControllerDelegate {

    func pickerController(_ viewController: ChapterPickerViewController, didPickChapter chapter: Chapter) {

        viewController.isLoading = true

        userApi.updateMyHomeChapter(with: chapter.id) { [weak self] user, error in
            if let user = user, user.homeChapterId == chapter.id {
                self?.updateMyHomeChapter(with: chapter)
                viewController.dismiss(animated: true)
            } else {
                viewController.isLoading = false
                Clog.log("Home Chapter Update error : \(error.debugDescription)")
            }
        }
    }
}

extension RaceFeedViewController: APISettingsDelegate {

    func didUpdate(settings: APISettingsType, with value: Any) {

        switch settings {
        case .showPastEvents, .searchRadius:
            unloadRaces() // invalidates collection
            loadRaces(forceReload: true)
        case .measurement:
            loadRaces() // simple refresh
        default:
            break
        }
    }
}

extension RaceFeedViewController: EmptyDataSetSource {

    func getEmptyStateViewModel() -> EmptyStateViewModel {
        switch selectedRaceFilter {
        case .joined:       return emptyStateJoinedRaces
        case .nearby:       return emptyStateNearbyRaces
        case .chapters:     return emptyStateChapterRaces
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

extension RaceFeedViewController: EmptyDataSetDelegate {

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }

    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {

        if selectedRaceFilter == .joined {
            selectSegment(.nearby)
        } else if selectedRaceFilter == .chapters {
            //
        } else if selectedRaceFilter == .nearby {
            didPressFilterButton(button)
        }
    }
}
