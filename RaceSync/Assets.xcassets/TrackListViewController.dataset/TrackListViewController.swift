//
//  TrackListViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-11-30.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import RaceSyncAPI
import SwiftyJSON

class TrackListViewController: ViewController {

    // MARK: - Private Variables

    fileprivate var trackList = [TrackViewModel]()
    fileprivate var sections = [Section]()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)

        let backgroundView = UIView()
        backgroundView.backgroundColor = Color.gray20
        tableView.backgroundView = backgroundView

        return tableView
    }()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = UniversalConstants.cellHeight
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        loadTracks()
        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    func setupLayout() {
        title = "Track Diagrams"

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
}

fileprivate extension TrackListViewController {

    func loadTracks() {
        guard let path = Bundle.main.path(forResource: "mgp_official_tracks", ofType: "json") else { return }
        guard let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else { return }

        let json = JSON(parseJSON: jsonString)

        // TODO: Move this to Track.swift
        func getTrackViewModels(with key: String) -> [TrackViewModel] {
            guard let array = json.dictionaryObject?[key] as? [[String : Any]] else { return [TrackViewModel]() }

            var tracks = [Track]()
            for dict in array {
                if let track = Track.init(JSON: dict) {
                    tracks += [track]
                }
            }

            // invert order to show more recent first
            let sortedTracks = tracks.sorted(by: { (c1, c2) -> Bool in
                return c1.id.lowercased() > c2.id.lowercased()
            })

            return TrackViewModel.viewModels(with: sortedTracks)
        }

        sections += [Section(title: "Global Qualifier (GQ)", viewModels: getTrackViewModels(with: "global_quali"))]
        sections += [Section(title: "Universal Time Trial (UTT)", viewModels: getTrackViewModels(with: "utt"))]
    }
}

extension TrackListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension TrackListViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].viewModels.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = sections[indexPath.section].viewModels[indexPath.row]
        return trackTableViewCell(for: viewModel)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UserTableViewCell.height
    }

    func trackTableViewCell(for viewModel: TrackViewModel) -> UserTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier) as! UserTableViewCell
        cell.avatarImageView.imageView.image = UIImage(named: "track_thumb_\(viewModel.track.id)")
        cell.avatarImageView.showShadow = false
        cell.avatarImageView.imageView.backgroundColor = .clear
        cell.titleLabel.text = viewModel.titleLabel
        cell.subtitleLabel.text = viewModel.subtitleLabel
        cell.accessoryType = .disclosureIndicator

        return cell
    }
}

fileprivate struct Section {
    let title : String
    let viewModels : [TrackViewModel]
}
