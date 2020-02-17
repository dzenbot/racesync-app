//
//  AircraftDetailViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-02-17.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import RaceSyncAPI

class AircraftDetailViewController: UIViewController {

    // MARK: - Private Variables

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()

        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.identifier)

        return tableView
    }()

    fileprivate let aircraftViewModel: AircraftViewModel
    fileprivate let aircraftApi = AircraftAPI()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = UniversalConstants.cellHeight
    }

    // MARK: - Initialization

    init(with aircraftViewModel: AircraftViewModel) {
        self.aircraftViewModel = aircraftViewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        title = aircraftViewModel.displayName

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

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension AircraftDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AircraftDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTableViewCell.identifier) as! FormTableViewCell

        cell.textLabel?.textColor = Color.gray300
        cell.detailTextLabel?.textColor = Color.black
        cell.accessoryType = .none

        if indexPath.row == 0 {
            cell.textLabel?.text = "Type"
            cell.detailTextLabel?.text = aircraftViewModel.typeLabel
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Size"
            cell.detailTextLabel?.text = aircraftViewModel.sizeLabel
        } else if indexPath.row == 2 {
            cell.textLabel?.text = "Battery"
            cell.detailTextLabel?.text = aircraftViewModel.batteryLabel
        } else if indexPath.row == 3 {
            cell.textLabel?.text = "Propeller Size"
            cell.detailTextLabel?.text = aircraftViewModel.propSizeLabel
        } else if indexPath.row == 4 {
            cell.textLabel?.text = "Video Tx"
            cell.detailTextLabel?.text = aircraftViewModel.videoTxTypeLabel
        } else if indexPath.row == 5 {
            cell.textLabel?.text = "Video Tx Power"
            cell.detailTextLabel?.text = aircraftViewModel.videoTxPowerLabel
        } else if indexPath.row == 6 {
            cell.textLabel?.text = "Video Tx Channels"
            cell.detailTextLabel?.text = aircraftViewModel.videoTxChannelsLabel
        } else if indexPath.row == 7 {
            cell.textLabel?.text = "Video Rx Channels"
            cell.detailTextLabel?.text = aircraftViewModel.videoRxChannelsLabel
        } else if indexPath.row == 8 {
            cell.textLabel?.text = "Antenna"
            cell.detailTextLabel?.text = aircraftViewModel.antennaLabel
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
