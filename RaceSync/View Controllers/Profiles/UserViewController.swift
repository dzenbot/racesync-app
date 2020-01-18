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

class UserViewController: ProfileViewController, Joinable {

    // MARK: - Private Variables

    fileprivate lazy var qrButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(didPressQRButton), for: .touchUpInside)
        button.setImage(UIImage(named: "icn_qrcode"), for: .normal)
        button.setBackgroundImage(nil, for: .normal)
        return button
    }()

    fileprivate let user: User
    fileprivate let raceApi = RaceApi()
    fileprivate let chapterApi = ChapterApi()

    fileprivate var raceViewModels = [RaceViewModel]()
    fileprivate var chapterViewModels = [ChapterViewModel]()
    fileprivate var presenter: Presentr?

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
    }

    // MARK: - Initialization

    init(with user: User) {
        self.user = user

        let profileViewModel = ProfileViewModel(with: user)
        super.init(with: profileViewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        if user.isMe {
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: qrButton)
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icn_share"), style: .done, target: self, action: #selector(didPressShareButton))
        }

        if navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icn_navbar_close"), style: .done, target: self, action: #selector(didPressCloseButton))
        }

        tableView.register(UserRaceTableViewCell.self, forCellReuseIdentifier: UserRaceTableViewCell.identifier)
        tableView.register(ChapterTableViewCell.self, forCellReuseIdentifier: ChapterTableViewCell.identifier)
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
            loadChapters()
        }
    }

    override func didPressLocationButton() {
        print("didPressLocationButton")
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
        dismiss(animated: true, completion: nil)
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
        guard let raceId = sender.raceId, let race = raceViewModels.race(withId: raceId) else { return }

        toggleJoinButton(sender, forRace: race, raceApi: raceApi) { (newState) in
            // Do something
        }
    }

    @objc func didPressShareButton() {
        let items = [URL(string: user.url)]
        var activities: [UIActivity] = [SafariActivity()]

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
                print("getRaces error : \(error.debugDescription)")
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
                print("getChapters error : \(error.debugDescription)")
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
        cell.joinButton.raceId = viewModel.race.id
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
