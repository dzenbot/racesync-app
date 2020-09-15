//
//  ChapterViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI
import EmptyDataSet_Swift
import CoreLocation

class ChapterViewController: ProfileViewController, ViewJoinable {

    // MARK: - Private Variables

    fileprivate lazy var joinButton: JoinButton = {
        let button = JoinButton(type: .system)
        button.addTarget(self, action: #selector(didPressJoinButton), for: .touchUpInside)
        button.hitTestEdgeInsets = UIEdgeInsets(proportionally: -10)
        button.type = .chapter
        button.objectId = chapter.id
        button.joinState = chapterViewModel.joinState
        return button
    }()

    fileprivate let chapter: Chapter
    fileprivate let raceApi = RaceApi()
    fileprivate let chapterApi = ChapterApi()

    fileprivate var raceViewModels = [RaceViewModel]()
    fileprivate var userViewModels = [UserViewModel]()
    fileprivate let chapterViewModel: ChapterViewModel
    fileprivate var chapterCoordinates: CLLocationCoordinate2D?

    fileprivate var emptyStateRaces = EmptyStateViewModel(.noRaces)
    fileprivate var emptyStateUsers = EmptyStateViewModel(.commingSoon)

    fileprivate var canCreateRaces: Bool = false

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let buttonHeight: CGFloat = 32
        static let buttonSpacing: CGFloat = 12
    }

    // MARK: - Initialization

    init(with chapter: Chapter) {
        self.chapter = chapter
        self.chapterViewModel = ChapterViewModel(with: chapter)

        let profileViewModel = ProfileViewModel(with: chapter)
        super.init(with: profileViewModel)

        if let latitude = CLLocationDegrees(chapter.latitude), let longitude = CLLocationDegrees(chapter.longitude) {
            self.chapterCoordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        configureBarButtonItems()

        tableView.register(RaceTableViewCell.self, forCellReuseIdentifier: RaceTableViewCell.identifier)
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
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

        headerView.addSubview(joinButton)
        joinButton.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-Constants.padding)
            $0.height.equalTo(Constants.buttonHeight)
        }
    }

    fileprivate func configureBarButtonItems() {

        var buttons = [UIButton]()

        if chapter.isMyChapter && canCreateRaces {
            let addButton = CustomButton(type: .system)
            addButton.addTarget(self, action: #selector(didPressAddButton), for: .touchUpInside)
            addButton.setImage(UIImage(named: "icn_navbar_add"), for: .normal)
            buttons += [addButton]
        }

        let shareButton = CustomButton(type: .system)
        shareButton.addTarget(self, action: #selector(didPressShareButton), for: .touchUpInside)
        shareButton.setImage(UIImage(named: "icn_navbar_share"), for: .normal)
        buttons += [shareButton]

        let rightStackView = UIStackView(arrangedSubviews: buttons)
        rightStackView.axis = .horizontal
        rightStackView.distribution = .fillEqually
        rightStackView.alignment = .lastBaseline
        rightStackView.spacing = Constants.buttonSpacing
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightStackView)

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
            loadUsers()
        }
    }

    override func didPressLocationButton() {
        guard let coordinates = chapterCoordinates else { return }

        let mapVC = MapViewController(with: coordinates, address: profileViewModel.locationName)
        mapVC.title = "Chapter Location"
        mapVC.showsDirection = false
        let mapNC = NavigationController(rootViewController: mapVC)

        present(mapNC, animated: true)
    }

    override func didSelectRow(at indexPath: IndexPath) {
        if selectedSegment == .left {
            let viewModel = raceViewModels[indexPath.row]
            let eventTVC = RaceTabBarController(with: viewModel.race.id) // pass the actual model object instead
            navigationController?.pushViewController(eventTVC, animated: true)
        } else {
            let viewModel = userViewModels[indexPath.row]
            if let user = viewModel.user {
                let userVC = UserViewController(with: user)
                navigationController?.pushViewController(userVC, animated: true)
            }
        }
    }

    @objc func didPressAddButton() {
        // Unimplemented
    }

    @objc func didPressCloseButton() {
        dismiss(animated: true)
    }
}

fileprivate extension ChapterViewController {

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
        raceApi.getRaces(forChapter: chapter.id) { (races, error) in
            if let races = races {
                // skip parent races for now
                let childRaces = races.filter({ (race) -> Bool in
                    return race.childRaceCount == nil
                })

                let sortedRaces = childRaces.sorted(by: { $0.startDate?.compare($1.startDate ?? Date()) == .orderedDescending })
                self.raceViewModels = RaceViewModel.viewModels(with: sortedRaces)
                self.tableView.reloadData()
            } else {
                Clog.log("getMyRaces error : \(error.debugDescription)")
            }

            completion?()
        }
    }

    func loadUsers() {
        if userViewModels.isEmpty {
            isLoading(true)

            fetchUsers { [weak self] in
                self?.isLoading(false)
            }
        } else {
            tableView.reloadData()
        }
    }

    func fetchUsers(_ completion: VoidCompletionBlock? = nil) {
        chapterApi.getChapterMembers(with: chapter.id) { (users, error) in
            if let users = users {
                let viewModels = UserViewModel.viewModels(with: users)
                self.userViewModels = viewModels.sorted { $0.username.lowercased() < $1.username.lowercased() }
                self.tableView.reloadData()
            } else {
                Clog.log("getMyRaces error : \(error.debugDescription)")
            }

            completion?()
        }
    }

    @objc func didPressJoinButton(_ sender: JoinButton) {
        guard let objectId = sender.objectId else { return }
        let joinState = sender.joinState

        if sender.type == .race, let race = raceViewModels.race(withId: objectId) {
            toggleJoinButton(sender, forRace: race, raceApi: raceApi) { [weak self] (newState) in
                if joinState != newState {
                    // reload races to reflect race changes, specially join counts
                    self?.fetchRaces(nil)
                }
            }
        } else if sender.type == .chapter {
            toggleJoinButton(sender, forChapter: chapter, chapterApi: chapterApi) { [weak self] (newState) in
                if joinState != newState {
                    self?.chapter.isJoined = (newState == .joined)
                    sender.joinState = newState
                }
            }
        }
    }

    @objc func didPressShareButton() {
        let items = [URL(string: chapter.url)]
        guard items.count > 0 else { return }

        let activities: [UIActivity] = [SafariActivity()]
        let activityVC = UIActivityViewController(activityItems: items as [Any], applicationActivities: activities)
        present(activityVC, animated: true)
    }
}

// MARK: - UITableView DataSource

extension ChapterViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedSegment == .left {
            return raceViewModels.count
        } else {
            return userViewModels.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if selectedSegment == .left {
            let viewModel = raceViewModels[indexPath.row]
            return raceTableViewCell(for: viewModel)
        } else {
            let viewModel = userViewModels[indexPath.row]
            return userTableViewCell(for: viewModel)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedSegment == .left {
            return RaceTableViewCell.height
        } else {
            return UserTableViewCell.height
        }
    }

    func raceTableViewCell(for viewModel: RaceViewModel) -> RaceTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RaceTableViewCell.identifier) as! RaceTableViewCell
        cell.dateLabel.text = viewModel.dateLabel //"Saturday Sept 14 @ 9:00 AM"
        cell.titleLabel.text = viewModel.titleLabel
        cell.joinButton.type = .race
        cell.joinButton.objectId = viewModel.race.id
        cell.joinButton.joinState = viewModel.joinState
        cell.joinButton.addTarget(self, action: #selector(didPressJoinButton), for: .touchUpInside)
        cell.memberBadgeView.count = viewModel.participantCount
        cell.avatarImageView.imageView.setImage(with: viewModel.imageUrl, placeholderImage: UIImage(named: "placeholder_medium"))
        cell.subtitleLabel.text = viewModel.locationLabel
        return cell
    }

    func userTableViewCell(for viewModel: UserViewModel) -> UserTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier) as! UserTableViewCell
        cell.titleLabel.text = viewModel.pilotName
        cell.avatarImageView.imageView.setImage(with: viewModel.pictureUrl, placeholderImage: UIImage(named: "placeholder_medium"))
        cell.subtitleLabel.text = viewModel.fullName
        return cell
    }
}

extension ChapterViewController: EmptyDataSetSource {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if selectedSegment == .left {
            return emptyStateRaces.title
        } else if selectedSegment == .right {
            return emptyStateUsers.title
        } else {
            return nil
        }
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        if selectedSegment == .left {
            return emptyStateRaces.description
        } else if selectedSegment == .right {
            return emptyStateUsers.description
        } else {
            return nil
        }
    }

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView) -> CGFloat {
        return 0
    }
}

extension ChapterViewController: EmptyDataSetDelegate {

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return true
    }
}
