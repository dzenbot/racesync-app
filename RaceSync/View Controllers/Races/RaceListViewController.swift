//
//  RaceListViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2022-12-11.
//  Copyright © 2022 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI
import SnapKit
import UIKit

/**
 Generic display of pre-loaded races.
 */
class RaceListViewController: UIViewController, ViewJoinable {

    // MARK: - Public Variables

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(cellType: RaceTableViewCell.self)
        tableView.tableFooterView = UIView()
        return tableView
    }()

    // MARK: - Private Variables

    fileprivate var raceList: [RaceViewModel]
    fileprivate let raceApi = RaceApi()
    fileprivate var seasonId: ObjectId?
    fileprivate var raceClass: String?

    // MARK: - Initialization

    /**
     Displays a list of season races.

     - parameter raceViewModels: The pre-fetched view model list of races
     - parameter seasonId: The season id, to be used in case of refreshing the list (particularly needed for state updates like joining)
     */
    init(_ raceViewModels: [RaceViewModel], seasonId: ObjectId) {
        self.raceList = raceViewModels
        self.seasonId = seasonId

        super.init(nibName: nil, bundle: nil)
    }

    /**
     Displays a list of races filtered by class

     - parameter raceViewModels: The pre-fetched view model list of races
     - parameter raceClass: The season enum raw value, to be used in case of refreshing the list (particularly needed for state updates like joining)
     */
    init(_ raceViewModels: [RaceViewModel], raceClass: String) {
        self.raceList = raceViewModels
        self.raceClass = raceClass

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.snp.bottom)
        }
    }

    // MARK: - Actions

    @objc fileprivate func didPressJoinButton(_ sender: JoinButton) {
        guard let objectId = sender.objectId, let race = raceList.race(withId: objectId) else { return }
        let joinState = sender.joinState

        toggleJoinButton(sender, forRace: race, raceApi: raceApi) { [weak self] (newState) in
            if joinState != newState {
                // reload races to reflect race changes, specially join counts
                self?.reloadRaces()
            }
        }
    }

    fileprivate func openRaceDetail(_ viewModel: RaceViewModel) {
        let vc = RaceTabBarController(with: viewModel.race.id)
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func reloadRaces() {
        if let seasonId = seasonId {
            raceApi.getRaces(forSeason: seasonId) { [weak self] (races, error) in
                if let races = races {
                    self?.raceList = RaceViewModel.sortedViewModels(with: races)
                    self?.tableView.reloadData()
                } else if let _ = error {
                    // handle error ?
                }
            }
        } else if let raceClass = raceClass {
            raceApi.getRaces(forClass: raceClass) { [weak self] (races, error) in
                if let races = races {
                    self?.raceList = RaceViewModel.sortedViewModels(with: races)
                    self?.tableView.reloadData()
                } else if let _ = error {
                    // handle error ?
                }
            }
        }
    }
}

extension RaceListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let viewModel = raceList[indexPath.row]
        openRaceDetail(viewModel)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return RaceTableViewCell.height
    }
}

extension RaceListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return raceList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as RaceTableViewCell
        let viewModel = raceList[indexPath.row]

        cell.dateLabel.text = viewModel.dateLabel //"Saturday Sept 14 @ 9:00 AM"
        cell.titleLabel.text = viewModel.titleLabel
        cell.joinButton.type = .race
        cell.joinButton.objectId = viewModel.race.id
        cell.joinButton.joinState = viewModel.joinState
        cell.joinButton.addTarget(self, action: #selector(didPressJoinButton), for: .touchUpInside)
        cell.memberBadgeView.count = viewModel.participantCount
        cell.avatarImageView.imageView.setImage(with: viewModel.imageUrl, placeholderImage: PlaceholderImg.medium)
        cell.subtitleLabel.text = viewModel.distanceLabel
        return cell
    }
}
