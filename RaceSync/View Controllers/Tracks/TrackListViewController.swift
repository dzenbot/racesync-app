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

class TrackListViewController: UIViewController {

    // MARK: - Private Variables

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(cellType: SimpleTableViewCell.self)

        let backgroundView = UIView()
        backgroundView.backgroundColor = Color.gray20
        tableView.backgroundView = backgroundView

        return tableView
    }()

    fileprivate var sections = [Section]()

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

    fileprivate func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
}

fileprivate extension TrackListViewController {

    func loadTracks() {
        guard let path = Bundle.main.path(forResource: "track-list", ofType: "json") else { return }
        guard let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else { return }

        let json = JSON(parseJSON: jsonString)

        // TODO: Move this to Track.swift
        func getTrackViewModels(with type: TrackType) -> [TrackViewModel] {
            guard let array = json.dictionaryObject?[type.rawValue] as? [[String : Any]] else { return [TrackViewModel]() }

            var tracks = [Track]()
            for dict in array {
                if let track = Track.init(JSON: dict) {
                    if track.elementsCount == 0 { continue } // skip track with no elements (dummies)
                    tracks += [track]
                }
            }

            // invert order to show more recent first
            let sortedTracks = tracks.sorted(by: { (c1, c2) -> Bool in
                return c1.id.localizedStandardCompare(c2.id) == .orderedDescending
            })

            return TrackViewModel.viewModels(with: sortedTracks)
        }

        func getSection(for type: TrackType) -> Section {
            return Section(title: type.title, viewModels: getTrackViewModels(with: type))
        }
        
        sections += [getSection(for: .gq)]
        sections += [getSection(for: .utt)]
        sections += [getSection(for: .champs)]
        sections += [getSection(for: .canada)]
    }

    func getViewModel(at indexPath: IndexPath) -> TrackViewModel {
        let section = sections[indexPath.section]
        return section.viewModels[indexPath.row]
    }
}

extension TrackListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let viewModel = getViewModel(at: indexPath)
        let vc = TrackDetailViewController(with: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
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
        return trackTableViewCell(for: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UniversalConstants.cellHeight
    }

    func trackTableViewCell(for indexPath: IndexPath) -> SimpleTableViewCell {
        let viewModel = getViewModel(at: indexPath)
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as SimpleTableViewCell
        cell.iconImageView.image = UIImage(named: "track_thumb_\(viewModel.track.id)")
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
