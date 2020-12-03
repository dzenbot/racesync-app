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

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        return tableView
    }()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = UniversalConstants.cellHeight
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadTracks()
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
        var objects = [Track]()

        for value in json.arrayValue {
            if let dict = value.dictionaryObject {
                if let track = Track.init(JSON: dict) {
                    objects += [track]
                }
            }
        }

        trackList = TrackViewModel.viewModels(with: objects)
        tableView.reloadData()


//        guard let path = Bundle.main.path(forResource: "mgp_official_tracks", ofType: "json") else { return }
//        do {
//            let text = try String(contentsOfFile: path)
//            if let dict = try JSONSerialization.jsonObject(with: text.data(using: .utf8)!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] {
//                if let data = Track(JSON: dict) {
//                    print(data.attributesDescription)
////                    trackList = TrackViewModel.viewModels(with: <#T##[Track]#>)
//                }
//            } else {
//
//            }
//        } catch {
//            print("\(error.localizedDescription)")
//        }

    }
}

extension TrackListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TrackListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trackList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = trackList[indexPath.row]

        let cell = UITableViewCell()
        cell.textLabel?.text = viewModel.titleLabel
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
}
