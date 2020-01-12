//
//  ChapterViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI
import TUSafariActivity

class ChapterViewController: ProfileViewController, Joinable {

    // MARK: - Private Variables

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = UniversalConstants.cellHeight
    }

    fileprivate let chapter: Chapter
    fileprivate let raceApi = RaceApi()

    fileprivate var raceViewModels = [RaceViewModel]()
    fileprivate var userViewModels = [UserViewModel]()

    // MARK: - Initialization

    init(with chapter: Chapter) {
        self.chapter = chapter

        let profileViewModel = ProfileViewModel(with: chapter)
        super.init(with: profileViewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icn_share"), style: .done, target: self, action: #selector(didPressShareButton))

        tableView.register(RaceTableViewCell.self, forCellReuseIdentifier: RaceTableViewCell.identifier)
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        tableView.dataSource = self

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
        print("didPressLocationButton")
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

                self.raceViewModels = RaceViewModel.viewModels(with: childRaces)
                self.tableView.reloadData()
            } else {
                print("getMyRaces error : \(error.debugDescription)")
            }

            completion?()
        }
    }

    func loadUsers() {
        if userViewModels.isEmpty {
            isLoading(true)

            // TODO: Just displaying the 1 complete User model we have, while we wait for https://github.com/mainedrones/racesync-api/issues/16
            if let myUser = APIServices.shared.myUser {
                self.userViewModels = UserViewModel.viewModels(with: [myUser])
                isLoading(false)
            }
        } else {
            tableView.reloadData()
        }
    }

    @objc func didPressJoinButton(_ sender: JoinButton) {
        guard let raceId = sender.raceId, let race = raceViewModels.race(withId: raceId) else { return }

        toggleJoinButton(sender, forRace: race, raceApi: raceApi) { (newState) in
            // Do something
        }
    }

    @objc func didPressShareButton() {
        let items = [URL(string: chapter.url)]

        let activity = TUSafariActivity()

        let activityVC = UIActivityViewController(activityItems: items as [Any], applicationActivities: [activity])
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
        cell.joinButton.raceId = viewModel.race.id
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
        cell.subtitleLabel.text = viewModel.displayName
        return cell
    }
}
