//
//  RaceListViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-14.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import CoreLocation
import RaceSyncAPI
import SnapKit
import ShimmerSwift
import EmptyDataSet_Swift

class RaceListViewController: UIViewController, Joinable, Shimmable {

    // MARK: - Feature Flags
    fileprivate var shouldShowSearchButton: Bool = false
    fileprivate var shouldLoadRaces: Bool = true

    // MARK: - Public Variables

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.register(RaceTableViewCell.self, forCellReuseIdentifier: RaceTableViewCell.identifier)
        tableView.refreshControl = self.refreshControl
        tableView.tableFooterView = UIView()

        for direction in [UISwipeGestureRecognizer.Direction.left, UISwipeGestureRecognizer.Direction.right] {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeHorizontally(_:)))
            gesture.direction = direction
            tableView.addGestureRecognizer(gesture)
        }

        return tableView
    }()

    var shimmeringView: ShimmeringView = defaultShimmeringView()

    // MARK: - Private Variables

    fileprivate let initialSelectedRaceSegment: RaceSegment = .joined

    fileprivate lazy var segmentedControl: UISegmentedControl = {
        let items = [RaceSegment.joined.title, RaceSegment.nearby.title]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.addTarget(self, action: #selector(didChangeSegment), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = initialSelectedRaceSegment.rawValue
        segmentedControl.tintColor = Color.blue
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
        refreshControl.backgroundColor = .white
        refreshControl.tintColor = Color.blue
        refreshControl.addTarget(self, action: #selector(didPullRefreshControl), for: .valueChanged)
        return refreshControl
    }()

    fileprivate lazy var titleView: UIView = {
        let view = UIView()
        let imageView = UIImageView(image: UIImage(named: "Racesync_Logo_Header"))
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.snp.top).offset(4)
        }
        return view
    }()

    fileprivate lazy var userProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didPressUserProfileButton), for: .touchUpInside)

        if let placeholder = UIImage(named: "placeholder_small")?.withRenderingMode(.alwaysOriginal) {
            button.setImage(placeholder, for: .normal) // 32x32
            button.layer.cornerRadius = placeholder.size.width / 2
            button.layer.masksToBounds = true
        }
        return button
    }()

    fileprivate let raceApi = RaceApi()
    fileprivate let userApi = UserApi()
    fileprivate let chapterApi = ChapterApi()
    fileprivate var raceList = [String: [RaceViewModel]]()

    fileprivate let locationManager = CLLocationManager()
    fileprivate var userLocation: CLLocation?

    fileprivate var emptyStateJoinedRaces = EmptyStateViewModel(.noJoinedRaces)
    fileprivate var emptyStateNearbyRaces = EmptyStateViewModel(.noNearbydRaces)

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let headerHeight: CGFloat = 50
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
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

        navigationItem.titleView = titleView
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: userProfileButton)

        if shouldShowSearchButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icn_search"), style: .done, target: self, action: #selector(didPressSearchButton))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icn_settings"), style: .done, target: self, action: #selector(didPressSettingsButton))
        }

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

        locationManager.delegate = self
    }

    // MARK: - Actions

    @objc fileprivate func didChangeSegment() {
        updateUserLocation()
        loadRaces()
    }

    func updateUserLocation() {
        guard selectedSegment == .nearby else { return }

        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    @objc fileprivate func didPressUserProfileButton() {
        guard let myUser = APIServices.shared.myUser else { return }

        let userVC = UserViewController(with: myUser)
        let userNC = NavigationController(rootViewController: userVC)
        userNC.modalPresentationStyle = .fullScreen

        present(userNC, animated: true, completion: nil)
    }

    @objc fileprivate func didPressSearchButton() {
        print("didPressSearchButton")
    }

    @objc fileprivate func didPressSettingsButton() {
        let settingsVC = SettingsViewController()
        let settingsNC = NavigationController(rootViewController: settingsVC)
        settingsNC.modalPresentationStyle = .fullScreen

        present(settingsNC, animated: true, completion: nil)
    }

    @objc func didPressJoinButton(_ sender: JoinButton) {
        guard let raceId = sender.raceId, let race = currentRaceList()?.race(withId: raceId) else { return }
        let joinState = sender.joinState

        toggleJoinButton(sender, forRace: race, raceApi: raceApi) { [weak self] (newState) in
            if joinState != newState {
                // reload races to reflect race changes, specially join counts
                self?.reloadRaces()
            }
        }
    }

    @objc func didPullRefreshControl() {
        updateUserLocation()
        reloadRaces()
    }

    @objc open func didSwipeHorizontally(_ sender: Any) {
        guard let swipeGesture = sender as? UISwipeGestureRecognizer else { return }

        if swipeGesture.direction == .left && selectedSegment != .nearby {
            segmentedControl.setSelectedSegment(RaceSegment.nearby.rawValue)
        } else if swipeGesture.direction == .right && selectedSegment != .joined {
            segmentedControl.setSelectedSegment(RaceSegment.joined.rawValue)
        }
    }
}

fileprivate extension RaceListViewController {

    func loadContent() {
        if APIServices.shared.myUser == nil {
            fetchMyUser()
            isLoading(true)
        } else {
            reloadRaces()
        }
    }

    func fetchMyUser() {
        userApi.getMyUser { (user, error) in
            APIServices.shared.myUser = user
            
            if user != nil && self.shouldLoadRaces {
                self.updateProfilePicture()
                self.loadRaces()
            } else if error != nil {
                // This is somewhat the best way to detect an invalid session
                ApplicationControl.shared.invalidateSession()
            }
        }

        chapterApi.getMyManagedChapters { (managedChapters, error) in
            APIServices.shared.myManagedChapters = managedChapters
        }
    }

    func loadRaces(_ force: Bool = false, completion: VoidCompletionBlock? = nil) {
        if currentRaceList() == nil || force {
            isLoading(true)
            fetchRaces(selectedRaceListFiltering()) { [weak self] in
                self?.isLoading(false)
                completion?()
            }
        } else {
            tableView.reloadData()
            reloadRaces()
        }
    }

    @objc func reloadRaces() {
        fetchRaces(selectedRaceListFiltering()) { [weak self] in
            if self?.refreshControl.isRefreshing ?? false {
                self?.refreshControl.endRefreshing()
            }
            self?.tableView.reloadData()
        }
    }

    func fetchRaces(_ filtering: RaceListFiltering, completion: VoidCompletionBlock? = nil) {

        let coordinate = userLocation?.coordinate
        let lat = coordinate?.latitude.string
        let long = coordinate?.longitude.string

        raceApi.getMyRaces(filtering: filtering, latitude: lat, longitude: long) { (races, error) in
            if let upcomingRaces = races?.filter({ (race) -> Bool in
                guard let startDate = race.startDate else { return false }
                return startDate.timeIntervalSinceNow.sign == .plus
            }) {
                let sortedRaces = upcomingRaces.sorted(by: { $0.startDate?.compare($1.startDate ?? Date()) == .orderedAscending })
                self.raceList[filtering.rawValue] = RaceViewModel.viewModels(with: sortedRaces)
            } else {
                print("getMyRaces error : \(error.debugDescription)")
            }

            completion?()
        }
    }

    var selectedSegment: RaceSegment {
        get {
            return RaceSegment(index: segmentedControl.selectedSegmentIndex)
        }
    }

    func selectedRaceListFiltering() -> RaceListFiltering {
        switch selectedSegment {
        case RaceSegment.joined:
            return .upcoming
        case RaceSegment.nearby:
            return .nearby
        }
    }

    func currentRaceList() -> [RaceViewModel]? {
        return raceList[selectedRaceListFiltering().rawValue]
    }

    func updateProfilePicture() {
        let userProfileUrl = APIServices.shared.myUser?.profilePictureUrl
        let userUrl = ImageUtil.getSizedUrl(userProfileUrl, size: CGSize(width: 32, height: 32))
        let placeholder = UIImage(named: "placeholder_small")?.withRenderingMode(.alwaysOriginal)
        userProfileButton.setImage(with: userUrl, placeholderImage: placeholder, forState: .normal)
    }
}

extension RaceListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let races = currentRaceList() else { return }

        let viewModel = races[indexPath.row]
        let eventTVC = RaceTabBarController(with: viewModel.race.id)
        navigationController?.pushViewController(eventTVC, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension RaceListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let races = currentRaceList() else { return 0 }
        return races.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let races = currentRaceList(),
            let cell = tableView.dequeueReusableCell(withIdentifier: RaceTableViewCell.identifier) as? RaceTableViewCell else {
            return UITableViewCell()
        }

        let viewModel = races[indexPath.row]

        cell.dateLabel.text = viewModel.dateLabel //"Saturday Sept 14 @ 9:00 AM"
        cell.titleLabel.text = viewModel.titleLabel
        cell.joinButton.raceId = viewModel.race.id
        cell.joinButton.joinState = viewModel.joinState
        cell.joinButton.addTarget(self, action: #selector(didPressJoinButton), for: .touchUpInside)
        cell.memberBadgeView.count = viewModel.participantCount
        cell.avatarImageView.imageView.setImage(with: viewModel.imageUrl, placeholderImage: UIImage(named: "placeholder_medium"))

        if selectedSegment == .joined {
            cell.subtitleLabel.text = viewModel.locationLabel
        } else {
            cell.subtitleLabel.text = viewModel.distanceLabel
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return RaceTableViewCell.height
    }
}

extension RaceListViewController: EmptyDataSetSource {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if selectedSegment == .joined {
            return emptyStateJoinedRaces.title
        } else {
            return emptyStateNearbyRaces.title
        }
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if selectedSegment == .joined {
            return emptyStateJoinedRaces.description
        } else {
            return emptyStateNearbyRaces.description
        }
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return nil
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        if selectedSegment == .joined {
            return emptyStateJoinedRaces.buttonTitle(state)
        } else {
            return emptyStateNearbyRaces.buttonTitle(state)
        }
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return -(navigationController?.navigationBar.frame.height ?? 0)
    }
}

extension RaceListViewController: EmptyDataSetDelegate {

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }

    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {

        if selectedSegment == .joined {
            segmentedControl.setSelectedSegment(RaceSegment.nearby.rawValue)
        } else {
            let settingsVC = SettingsViewController()
            settingsVC.promptSearchRadiusPicker = true
            let settingsNC = NavigationController(rootViewController: settingsVC)
            present(settingsNC, animated: true, completion: nil)
        }
    }
}

extension RaceListViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("User Location's did dhange Authorization \(status)")

        if status == .authorizedWhenInUse {
            updateUserLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            userLocation = location
            print("Found user's location: \(location)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}

fileprivate enum RaceSegment: Int {
    case joined, nearby

    init(index: Int) {
        switch index {
        case 1 : self = .nearby
        default: self = .joined
        }
    }

    var title: String {
        switch self {
        case .joined:   return "Joined Races"
        case .nearby:   return "Nearby Races"
        }
    }
}
