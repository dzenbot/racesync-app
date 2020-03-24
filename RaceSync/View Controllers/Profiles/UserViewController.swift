//
//  UserViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import RaceSyncAPI
import Presentr
import EmptyDataSet_Swift
import CoreLocation

class UserViewController: ProfileViewController, ViewJoinable {

    // MARK: - Private Variables

    fileprivate let shouldShowStats: Bool = false

    fileprivate lazy var qrButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didPressQRButton), for: .touchUpInside)
        button.setImage(UIImage(named: "icn_qrcode"), for: .normal)
        button.setBackgroundImage(nil, for: .normal)
        return button
    }()

    fileprivate lazy var aircraftButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didPressAircraftButton), for: .touchUpInside)

        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        button.setTitleColor(Color.white, for: .normal)

        let title = user.isMe ? "My Aircrafts" : "Aircrafts"
        button.setTitle(title, for: .normal)

        button.contentEdgeInsets = UIEdgeInsets(top: 5, left: 12, bottom: 5, right: 12)
        button.backgroundColor = Color.blue
        button.layer.cornerRadius = Constants.buttonHeight/4

        return button
    }()

    fileprivate let user: User
    fileprivate let raceApi = RaceApi()
    fileprivate let chapterApi = ChapterApi()

    fileprivate var raceViewModels = [RaceViewModel]()
    fileprivate var chapterViewModels = [ChapterViewModel]()
    fileprivate var presenter: Presentr?
    fileprivate var userCoordinates: CLLocationCoordinate2D?

    fileprivate var emptyStateRaces = EmptyStateViewModel(.noProfileRaces)
    fileprivate var emptyStateChapters = EmptyStateViewModel(.noProfileChapters)
    fileprivate var emptyStateMyRaces = EmptyStateViewModel(.noMyProfileRaces)
    fileprivate var emptyStateMyChapters = EmptyStateViewModel(.noMyProfileChapters)

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let buttonHeight: CGFloat = 32
        static let buttonSpacing: CGFloat = 12
    }

    // MARK: - Initialization

    init(with user: User) {
        self.user = user

        let profileViewModel = ProfileViewModel(with: user)
        super.init(with: profileViewModel)

        if let latitude = CLLocationDegrees(user.latitude), let longitude = CLLocationDegrees(user.longitude) {
            self.userCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        configureBarButtonItems()

        // TODO: Remove once https://github.com/MultiGP/racesync-api/issues/11 is addressed
        if !shouldShowStats {
            headerView.hideLeftBadgeButton(true)
            headerView.hideRightBadgeButton(true)
        }

        tableView.register(UserRaceTableViewCell.self, forCellReuseIdentifier: UserRaceTableViewCell.identifier)
        tableView.register(ChapterTableViewCell.self, forCellReuseIdentifier: ChapterTableViewCell.identifier)
        tableView.dataSource = self
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        
        loadRaces()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    override func setupLayout() {
        super.setupLayout()

        headerView.addSubview(aircraftButton)
        aircraftButton.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-Constants.padding)
            $0.height.equalTo(Constants.buttonHeight)
        }
    }

    fileprivate func configureBarButtonItems() {

        var buttons = [UIButton]()

        if user.isMe {
            buttons += [qrButton]
        }

        let shareButton = CustomButton(type: .system)
        shareButton.addTarget(self, action: #selector(didPressShareButton), for: .touchUpInside)
        shareButton.setImage(UIImage(named: "icn_share"), for: .normal)
        buttons += [shareButton]

        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .lastBaseline
        stackView.spacing = Constants.buttonSpacing
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: stackView)

        if navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icn_navbar_close"), style: .done, target: self, action: #selector(didPressCloseButton))
        }
    }

    // MARK: - Actions

    override func didChangeSegment() {
        super.didChangeSegment()

        if selectedSegment == .left {
            loadRaces()
        } else {
            loadChapters()
        }
    }

    override func didPressLocationButton() {
        guard let coordinates = userCoordinates else { return }

        let mapVC = MapViewController(with: coordinates, address: profileViewModel.locationName)
        mapVC.title = "User Location"
        mapVC.showsDirection = false
        let mapNC = NavigationController(rootViewController: mapVC)

        present(mapNC, animated: true)
    }

    override func didSelectRow(at indexPath: IndexPath) {
        if selectedSegment == .left {
            let viewModel = raceViewModels[indexPath.row]
            let eventTVC = RaceTabBarController(with: viewModel.race.id)
            navigationController?.pushViewController(eventTVC, animated: true)
        } else {
            let viewModel = chapterViewModels[indexPath.row]
            let eventTVC = ChapterViewController(with: viewModel.chapter)
            navigationController?.pushViewController(eventTVC, animated: true)
        }
    }

    @objc func didPressCloseButton() {
        dismiss(animated: true)
    }

    @objc func didPressAircraftButton() {
        let aircraftVC = AircraftListViewController(with: user)
        aircraftVC.isEditable = user.isMe
        navigationController?.pushViewController(aircraftVC, animated: true)
    }

    @objc func didPressQRButton() {
        let QRVC = QRViewController(with: user.id)

        let presenter = Presentr(presentationType: .fullScreen)
        presenter.blurBackground = false
        presenter.backgroundOpacity = 0.65
        presenter.transitionType = .crossDissolve
        presenter.dismissTransitionType = .crossDissolve
        presenter.dismissAnimated = true
        presenter.dismissOnSwipe = false
        presenter.backgroundTap = .dismiss
        presenter.outsideContextTap = .passthrough

        customPresentViewController(presenter, viewController: QRVC, animated: true)
        self.presenter = presenter
    }

    @objc func didPressJoinButton(_ sender: JoinButton) {
        guard let objectId = sender.objectId, let race = raceViewModels.race(withId: objectId) else { return }
        let joinState = sender.joinState

        toggleJoinButton(sender, forRace: race, raceApi: raceApi) { [weak self] (newState) in
            if joinState != newState {
                // reload races to reflect race changes, specially join counts
                self?.fetchRaces(nil)
            }
        }
    }

    @objc func didPressShareButton() {
        let items = [URL(string: user.url)]
        let activities: [UIActivity] = [SafariActivity()]

        let activityVC = UIActivityViewController(activityItems: items as [Any], applicationActivities: activities)
        present(activityVC, animated: true)
    }
}

fileprivate extension UserViewController {

    func loadRaces() {
        if raceViewModels.isEmpty {
            isLoading(true)

            fetchRaces { [weak self] in
                self?.isLoading(false)
            }
        } else {
            tableView.reloadData()
        }
    }

    func fetchRaces(_ completion: VoidCompletionBlock? = nil) {
        raceApi.getRaces(forUser: user.id, filtering: .all) { (races, error) in
            if let races = races {
                let sortedRaces = races.sorted(by: { $0.startDate?.compare($1.startDate ?? Date()) == .orderedDescending })
                self.raceViewModels = RaceViewModel.viewModels(with: sortedRaces)
            } else {
                Clog.log("getRaces error : \(error.debugDescription)")
            }

            completion?()
        }
    }

    func loadChapters() {
        if chapterViewModels.isEmpty {
            isLoading(true)

            fetchChapters { [weak self] in
                self?.isLoading(false)
            }
        } else {
            tableView.reloadData()
        }
    }

    func fetchChapters(_ completion: VoidCompletionBlock? = nil) {
        chapterApi.getChapters(forUser: user.id) { (chapters, error) in
            if let chapters = chapters {
                self.chapterViewModels = ChapterViewModel.viewModels(with: chapters)
            } else {
                Clog.log("getChapters error : \(error.debugDescription)")
            }

            completion?()
        }
    }
}

// MARK: - UITableView DataSource

extension UserViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedSegment == .left {
            return raceViewModels.count
        } else {
            return chapterViewModels.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedSegment == .left {
            let viewModel = raceViewModels[indexPath.row]
            return userRaceTableViewCell(for: viewModel)
        } else {
            let viewModel = chapterViewModels[indexPath.row]
            return chapterTableViewCell(for: viewModel)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedSegment == .left {
            return UserRaceTableViewCell.height
        } else {
            return ChapterTableViewCell.height
        }
    }

    func userRaceTableViewCell(for viewModel: RaceViewModel) -> UserRaceTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserRaceTableViewCell.identifier) as! UserRaceTableViewCell
        cell.dateLabel.text = viewModel.dateLabel //"Saturday Sept 14 @ 9:00 AM"
        cell.titleLabel.text = viewModel.titleLabel
        cell.joinButton.type = .race
        cell.joinButton.objectId = viewModel.race.id
        cell.joinButton.joinState = viewModel.joinState
        cell.joinButton.addTarget(self, action: #selector(didPressJoinButton), for: .touchUpInside)
        cell.memberBadgeView.count = viewModel.participantCount
        cell.avatarImageView.imageView.setImage(with: viewModel.imageUrl, placeholderImage: UIImage(named: "placeholder_medium"))
        return cell
    }

    func chapterTableViewCell(for viewModel: ChapterViewModel) -> ChapterTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChapterTableViewCell.identifier) as! ChapterTableViewCell
        cell.titleLabel.text = viewModel.titleLabel
        cell.subtitleLabel.text = viewModel.locationLabel
        cell.avatarImageView.imageView.setImage(with: viewModel.imageUrl, placeholderImage: UIImage(named: "placeholder_medium"))
        return cell
    }
}

extension UserViewController: EmptyDataSetSource {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if selectedSegment == .left {
            return user.isMe ? emptyStateMyRaces.title : emptyStateRaces.title
        } else if selectedSegment == .right {
            return user.isMe ? emptyStateMyChapters.title : emptyStateChapters.title
        } else {
            return nil
        }
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if selectedSegment == .left {
            return user.isMe ? emptyStateMyRaces.description : emptyStateRaces.description
        } else if selectedSegment == .right {
            return user.isMe ? emptyStateMyChapters.description : emptyStateChapters.description
        } else {
            return nil
        }
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return 0
    }
}

extension UserViewController: EmptyDataSetDelegate {

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
}

