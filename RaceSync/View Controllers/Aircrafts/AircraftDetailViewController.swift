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
import Presentr

protocol AircraftDetailViewControllerDelegate {
    func aircraftDetailViewController(_ viewController: AircraftDetailViewController, didDeleteAircraft aircraftId: ObjectId)
}

class AircraftDetailViewController: UIViewController {

    // MARK: - Public Variables

    var delegate: AircraftDetailViewControllerDelegate?

    // MARK: - Private Variables

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.identifier)
        return tableView
    }()

    fileprivate lazy var deleteButton: ActionButton = {
        let button = ActionButton(type: .system)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 21, weight: .regular)
        button.setTitleColor(Color.white, for: .normal)
        button.setTitle("Delete Aircraft", for: .normal)
        button.backgroundColor = Color.red
        button.layer.cornerRadius = Constants.padding/2
        button.addTarget(self, action:#selector(didPressDeleteButton), for: .touchUpInside)
        button.spinnerView.color = Color.white
        return button
    }()

    fileprivate lazy var presenter: Presentr = {
        let presenter = Presentr(presentationType: .bottomHalf)
        presenter.blurBackground = false
        presenter.backgroundOpacity = 0.2
        presenter.transitionType = .coverVertical
        presenter.dismissTransitionType = .coverVertical
        presenter.dismissAnimated = true
        presenter.dismissOnSwipe = true
        presenter.backgroundTap = .dismiss
        presenter.outsideContextTap = .passthrough
        presenter.roundCorners = true
        presenter.cornerRadius = 10
        return presenter
    }()

    fileprivate let aircraftViewModel: AircraftViewModel
    fileprivate let aircraftApi = AircraftAPI()

    fileprivate var selectedRow: AircraftRow?

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = 50
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

        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Constants.cellHeight*2))
        footerView.backgroundColor = Color.white

        footerView.addSubview(deleteButton)
        deleteButton.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(Constants.padding)
            $0.trailing.equalToSuperview().offset(-Constants.padding)
            $0.height.equalTo(Constants.cellHeight)
        }

        tableView.tableFooterView = footerView
    }

    // MARK: - Button Events

    @objc func didPressDeleteButton() {

        let aircraftId = aircraftViewModel.aircraftId
        deleteButton.isLoading = true

        aircraftApi.delete(aircraft: aircraftId) { [weak self] (status, error)  in
            guard let strongSelf = self else { return }
            if status {
                strongSelf.delegate?.aircraftDetailViewController(strongSelf, didDeleteAircraft: aircraftId)
            } else if let _ = error {
                strongSelf.deleteButton.isLoading = false
            }
        }
    }
}

extension AircraftDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let row = AircraftRow(rawValue: indexPath.row) else { return }

        let items = AircraftType.allCases.compactMap { $0.title }
        let selectedItem = aircraftViewModel.aircraft?.type?.title

        let pickerVC = PickerViewController(with: items, selectedItem: selectedItem)
        pickerVC.title = "Updated \(row.title)"

        customPresentViewController(presenter, viewController: pickerVC, animated: true)
    }
}

extension AircraftDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTableViewCell.identifier) as! FormTableViewCell

        let row = AircraftRow(rawValue: indexPath.row)

        cell.textLabel?.textColor = Color.gray300
        cell.detailTextLabel?.textColor = Color.black
        cell.accessoryType = .none

        cell.textLabel?.text = row?.title

        switch row {
        case .type:
        cell.detailTextLabel?.text = aircraftViewModel.typeLabel
        case .size:
        cell.detailTextLabel?.text = aircraftViewModel.sizeLabel
        case .battery:
        cell.detailTextLabel?.text = aircraftViewModel.batteryLabel
        case .propSize:
        cell.detailTextLabel?.text = aircraftViewModel.propSizeLabel
        case .videoTx:
        cell.detailTextLabel?.text = aircraftViewModel.videoTxTypeLabel
        case .videoTxPower:
        cell.detailTextLabel?.text = aircraftViewModel.videoTxPowerLabel
        case .videoTxChannels:
        cell.detailTextLabel?.text = aircraftViewModel.videoTxChannelsLabel
        case .videoRxChannels:
        cell.detailTextLabel?.text = aircraftViewModel.videoRxChannelsLabel
        case .antenna:
        cell.detailTextLabel?.text = aircraftViewModel.antennaLabel
        case .none:
        cell.detailTextLabel?.text = ""
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
}

fileprivate enum AircraftRow: Int, EnumTitle, CaseIterable {
    case type, size, battery, propSize, videoTx, videoTxPower, videoTxChannels, videoRxChannels, antenna

    public var title: String {
        switch self {
        case .type:             return "Type"
        case .size:             return "Size"
        case .battery:          return "Battery"
        case .propSize:         return "Propeller Size"
        case .videoTx:          return "Video Tx"
        case .videoTxPower:     return "Video Tx Power"
        case .videoTxChannels:  return "Video Tx Channels"
        case .videoRxChannels:  return "Video Rx Channels"
        case .antenna:          return "Antenna"
        }
    }
}
