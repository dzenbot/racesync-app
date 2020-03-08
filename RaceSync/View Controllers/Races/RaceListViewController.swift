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

    fileprivate lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl()
        segmentedControl.addTarget(self, action: #selector(didChangeSegment), for: .valueChanged)
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

    fileprivate lazy var filterButton: CustomButton = {
        let button = CustomButton(type: .system)
        button.addTarget(self, action: #selector(didPressFilterButton), for: .touchUpInside)
        button.setImage(UIImage(named: "icn_filter"), for: .normal)
        button.isEnabled = false
        return button
    }()

    fileprivate lazy var settingsButton: CustomButton = {
        let button = CustomButton(type: .system)
        button.addTarget(self, action: #selector(didPressSettingsButton), for: .touchUpInside)
        button.setImage(UIImage(named: "icn_settings"), for: .normal)
        return button
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

    fileprivate var selectedRaceList: RaceListType {
        get {
            return RaceListType(rawValue: segmentedControl.selectedSegmentIndex)!
        }
    }

    fileprivate let raceListController: RaceListController
    fileprivate let raceApi = RaceApi()
    fileprivate let userApi = UserApi()
    fileprivate let chapterApi = ChapterApi()
    fileprivate var raceList = [RaceViewModel]()

    fileprivate let locationManager = CLLocationManager()
    fileprivate var userLocation: CLLocation?
    fileprivate var settingsController = SettingsController()

    fileprivate var emptyStateJoinedRaces = EmptyStateViewModel(.noJoinedRaces)
    fileprivate var emptyStateNearbyRaces = EmptyStateViewModel(.noNearbydRaces)

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let headerHeight: CGFloat = 50
        static let buttonSpacing: CGFloat = 12
    }

    // MARK: - Lifecycle Methods

    init(_ types: [RaceListType]) {
        self.raceListController = RaceListController(types)

        super.init(nibName: nil, bundle: nil)

        self.segmentedControl.setItems(types.compactMap { $0.title })
        self.segmentedControl.selectedSegmentIndex = 0
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            let stackView = UIStackView(arrangedSubviews: [filterButton, settingsButton])
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.alignment = .lastBaseline
            stackView.spacing = Constants.buttonSpacing
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: stackView)
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

        filterButton.isEnabled = (selectedRaceList == .nearby)
    }

    fileprivate func updateUserLocation() {
        guard selectedRaceList == .nearby else { return }

        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }

    fileprivate func stopUpdatingLocation() {
        guard selectedRaceList == .nearby else { return }
        locationManager.stopUpdatingLocation()
    }

    @objc fileprivate func didPressUserProfileButton() {
        guard let myUser = APIServices.shared.myUser else { return }

        let userVC = UserViewController(with: myUser)
        let userNC = NavigationController(rootViewController: userVC)
        userNC.modalPresentationStyle = .fullScreen

        present(userNC, animated: true, completion: nil)
    }

    @objc fileprivate func didPressSearchButton(_ sender: Any) {
        print("didPressSearchButton")
    }

    @objc fileprivate func didPressSettingsButton(_ sender: Any) {
        let settingsVC = SettingsViewController()
        let settingsNC = NavigationController(rootViewController: settingsVC)
        settingsNC.modalPresentationStyle = .fullScreen

        present(settingsNC, animated: true, completion: nil)
    }

    @objc fileprivate func didPressFilterButton(_ sender: Any) {
        settingsController.presentSettingsPicker(.searchRadius, from: self) { [weak self] in
            self?.isLoading(true)
            self?.loadRaces(forceReload: true)
        }
    }

    @objc fileprivate func didPressJoinButton(_ sender: JoinButton) {
        guard let raceId = sender.raceId, let race = raceList.race(withId: raceId) else { return }
        let joinState = sender.joinState

        toggleJoinButton(sender, forRace: race, raceApi: raceApi) { [weak self] (newState) in
            if joinState != newState {
                // reload races to reflect race changes, specially join counts
                self?.loadRaces(forceReload: true)
            }
        }
    }

    @objc fileprivate func didPullRefreshControl() {
        updateUserLocation()
        loadRaces(forceReload: true)
    }

    fileprivate func openRaceDetail(_ viewModel: RaceViewModel) {
        let eventTVC = RaceTabBarController(with: viewModel.race.id)
        eventTVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(eventTVC, animated: true)
    }

    @objc fileprivate func didSwipeHorizontally(_ sender: Any) {
        guard let swipeGesture = sender as? UISwipeGestureRecognizer else { return }

        if swipeGesture.direction == .left && selectedRaceList.rawValue != 1 {
            toggleSegmentedControl()
        } else if swipeGesture.direction == .right && selectedRaceList.rawValue != 0 {
            toggleSegmentedControl()
        }
    }

    fileprivate func toggleSegmentedControl() {
        var nextSegment = 0
        if selectedRaceList.rawValue == 0 {
            nextSegment += 1
        }
        segmentedControl.setSelectedSegment(nextSegment)
    }
}

fileprivate extension RaceListViewController {

    func loadContent() {
        if APIServices.shared.myUser == nil {
            isLoading(true)
            loadMyUser()
        } else {
            loadRaces(forceReload: true)
        }
    }

    func loadMyUser() {
        userApi.getMyUser { (user, error) in
            APIServices.shared.myUser = user
            
            if user != nil {
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

    @objc func loadRaces(forceReload: Bool = false) {
        if raceListController.shouldShowShimmer(for: selectedRaceList) {
            isLoading(true)
        }

        raceListController.raceViewModels(for: selectedRaceList, userLocation: userLocation, forceFetch: forceReload) { [weak self] (viewModels, error) in
            self?.isLoading(false)

            if let viewModels = viewModels {
                self?.raceList = viewModels

                if self?.refreshControl.isRefreshing ?? false {
                    self?.refreshControl.endRefreshing()
                }

                self?.tableView.reloadData()
            } else {
                print("getMyRaces error : \(error.debugDescription)")
            }
        }
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
        tableView.deselectRow(at: indexPath, animated: true)

        let viewModel = raceList[indexPath.row]
        openRaceDetail(viewModel)
    }
}

extension RaceListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return raceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: RaceTableViewCell.identifier) as? RaceTableViewCell else {
            return UITableViewCell()
        }

        let viewModel = raceList[indexPath.row]

        cell.dateLabel.text = viewModel.dateLabel //"Saturday Sept 14 @ 9:00 AM"
        cell.titleLabel.text = viewModel.titleLabel
        cell.joinButton.raceId = viewModel.race.id
        cell.joinButton.joinState = viewModel.joinState
        cell.joinButton.addTarget(self, action: #selector(didPressJoinButton), for: .touchUpInside)
        cell.memberBadgeView.count = viewModel.participantCount
        cell.avatarImageView.imageView.setImage(with: viewModel.imageUrl, placeholderImage: UIImage(named: "placeholder_medium"))

        if selectedRaceList == .joined {
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
        if selectedRaceList == .joined {
            return emptyStateJoinedRaces.title
        } else {
            return emptyStateNearbyRaces.title
        }
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if selectedRaceList == .joined {
            return emptyStateJoinedRaces.description
        } else {
            return emptyStateNearbyRaces.description
        }
    }

    func image(forEmptyDataSet scrollView: UIScrollView) -> UIImage? {
        return nil
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        if selectedRaceList == .joined {
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

        if selectedRaceList == .joined {
            toggleSegmentedControl()
        } else if selectedRaceList == .nearby {
            didPressFilterButton(button)
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
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Clog.log("Failed to find user's location: \(error.localizedDescription)", andLevel: .error)
    }
}
