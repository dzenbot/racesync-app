//
//  MyRacesListViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-14.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI
import AlamofireImage

class MyRacesListViewController: UIViewController, Joinable {

    // MARK: - Feature Flags
    fileprivate var shouldShowSearchButton: Bool = false
    fileprivate var shouldLoadRaces: Bool = true

    // MARK: - Private Variables

    fileprivate var initialSelectedListType: RaceListType = .joined

    fileprivate lazy var segmentedControl: UISegmentedControl = {
        let items = [RaceListType.joined.title, RaceListType.nearby.title]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.addTarget(self, action: #selector(didChangeSegment), for: .valueChanged)
        segmentedControl.selectedSegmentIndex = initialSelectedListType.rawValue
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

    // TODO: Break it down into 1 tableView for each section. Should keep the scroll offset intact as well as less
    // computing when switching segments. More optimal and practical.
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RaceTableViewCell.self, forCellReuseIdentifier: RaceTableViewCell.identifier)
        tableView.refreshControl = self.refreshControl
        tableView.tableFooterView = UIView()
        return tableView
    }()

    fileprivate lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .white
        refreshControl.tintColor = Color.blue
        refreshControl.addTarget(self, action: #selector(reloadDataFromPull), for: .valueChanged)
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

    fileprivate lazy var searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didPressSearchButton), for: .touchUpInside)
        button.setImage(UIImage(named: "icn_search"), for: .normal)
        return button
    }()

    fileprivate let raceApi = RaceApi()
    fileprivate let userApi = UserApi()
    fileprivate var raceList = [String: [RaceViewModel]]()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let headerHeight: CGFloat = 50
        static let cellHeight: CGFloat = 96
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        fetchMyUser()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        navigationItem.titleView = titleView
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: userProfileButton)

        if shouldShowSearchButton {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchButton)
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
    }

    // MARK: - Actions

    @objc fileprivate func didChangeSegment() {
        loadRaces()
    }

    @objc fileprivate func didPressUserProfileButton() {
        guard let myUser = APIServices.shared.myUser else { return }

        let userVC = UserViewController(with: myUser)
        let userNC = UINavigationController(rootViewController: userVC)
        userNC.modalPresentationStyle = .fullScreen

        present(userNC, animated: true, completion: nil)
    }

    @objc fileprivate func didPressSearchButton() {
        print("didPressSearchButton")
    }

    @objc fileprivate func reloadDataFromPull() {
        fetchRaces(selectedRaceListFiltering()) {
            self.refreshControl.endRefreshing()
        }
    }

    @objc func didPressJoinButton(_ sender: JoinButton) {
        guard let raceId = sender.raceId else { return }

        toggleJoinButton(sender, forRaceId: raceId, raceApi: raceApi) { (newState) in
            // do something
        }
    }
}

fileprivate extension MyRacesListViewController {

    func fetchMyUser() {
        userApi.getMyUser { (user, error) in
            APIServices.shared.myUser = user

            if user != nil && self.shouldLoadRaces {
                self.updateProfilePicture()
                self.loadRaces()
            } else if error != nil {
                print("fetchMyUser error : \(error.debugDescription)")
                
                // Invalidate session id
                self.dismiss(animated: true, completion: nil)
            }
        }
    }

    func loadRaces() {
        if currentRaceList() == nil {
            tableView.reloadData()
            fetchRaces(selectedRaceListFiltering())
        } else {
            tableView.reloadData()
        }
    }

    func fetchRaces(_ filtering: RaceListFiltering, completion: VoidCompletionBlock? = nil) {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateUtil.standardFormat

        raceApi.getMyRaces(filtering: filtering) { (races, error) in

            if let upcomingRaces = races?.filter({ (race) -> Bool in
                guard let startDate = race.startDate else { return false }
                return startDate.timeIntervalSinceNow.sign == .plus
            }) {
                let filteredRaces = upcomingRaces.sorted(by: { $0.startDate?.compare($1.startDate ?? Date()) == .orderedAscending })

                self.raceList[filtering.rawValue] = RaceViewModel.viewModels(with: filteredRaces)
                self.tableView.reloadData()
            } else {
                print("getMyRaces error : \(error.debugDescription)")
            }

            completion?()
        }
    }

    func selectedRaceListType() -> RaceListType {
        return RaceListType(index: segmentedControl.selectedSegmentIndex)
    }

    func selectedRaceListFiltering() -> RaceListFiltering {
        switch selectedRaceListType() {
        case RaceListType.joined:
            return .upcoming
        case RaceListType.nearby:
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

extension MyRacesListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let races = currentRaceList() else { return }

        let viewModel = races[indexPath.row]
        let eventTVC = RaceTabBarController(with: viewModel)
        navigationController?.pushViewController(eventTVC, animated: true)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MyRacesListViewController: UITableViewDataSource {

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

        if selectedRaceListType() == .nearby {
            cell.subtitleLabel.text = viewModel.distanceLabel
        } else {
            cell.subtitleLabel.text = viewModel.locationLabel
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
}

fileprivate enum RaceListType: Int {
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
