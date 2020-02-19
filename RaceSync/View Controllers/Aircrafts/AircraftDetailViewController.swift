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

    let shouldDisplayHeader: Bool = false

    // MARK: - Public Variables

    var delegate: AircraftDetailViewControllerDelegate?

    // MARK: - Private Variables

    let headerView = ProfileHeaderView()

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.identifier)
        tableView.contentInsetAdjustmentBehavior = .scrollableAxes
        tableView.tableFooterView = UIView()
        return tableView
    }()

    fileprivate var topOffset: CGFloat {
        get {
            let status_height = UIApplication.shared.statusBarFrame.height
            let navi_height = navigationController?.navigationBar.frame.size.height ?? 44
            return status_height + navi_height
        }
    }

    fileprivate var aircraftViewModel: AircraftViewModel
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

        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    func setupLayout() {
        guard let aircraft = aircraftViewModel.aircraft else { return }

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didPressDeleteButton))
        navigationItem.rightBarButtonItem?.tintColor = Color.red

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }

        if shouldDisplayHeader {
            headerView.topLayoutInset = topOffset
            headerView.viewModel = ProfileViewModel(with: aircraft)
            tableView.tableHeaderView = headerView

            let headerViewSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            headerView.snp.makeConstraints {
                $0.size.equalTo(headerViewSize)
            }
        }
    }

    fileprivate func presentPicker(forRow row: AircraftRow) {
        let items = aircraftSpecs(forRow: row)
        let selectedItem = selectedAircraftSpec(forRow: row)

        let presenter = Appearance.defaultPresenter()
        let pickerVC = PickerViewController(with: items, selectedItem: selectedItem)
        pickerVC.delegate = self
        pickerVC.title = "Update \(row.title)"

        customPresentViewController(presenter, viewController: pickerVC, animated: true)
    }

    fileprivate func aircraftSpecs(forRow row: AircraftRow) -> [String] {
        switch row {
        case .type:
            return AircraftType.allCases.compactMap { $0.title }
        case .size:
            return AircraftSize.allCases.compactMap { $0.title }
        case .battery:
            return BatterySize.allCases.compactMap { $0.title }
        case .propSize:
            return PropellerSize.allCases.compactMap { $0.title }
        case .videoTx:
            return VideoTxType.allCases.compactMap { $0.title }
        case .videoTxPower:
            return VideoTxPower.allCases.compactMap { $0.title }
        case .videoTxChannels:
            return VideoChannels.allCases.compactMap { $0.title }
        case .videoRxChannels:
            return VideoChannels.allCases.compactMap { $0.title }
        case .antenna:
            return AntennaPolarization.allCases.compactMap { $0.title }
        }
    }

    fileprivate func selectedAircraftSpec(forRow row: AircraftRow) -> String? {
        switch row {
        case .type:
            return aircraftViewModel.aircraft?.type?.title
        case .size:
            return aircraftViewModel.aircraft?.size?.title
        case .battery:
            return aircraftViewModel.aircraft?.battery?.title
        case .propSize:
            return aircraftViewModel.aircraft?.propSize?.title
        case .videoTx:
            return aircraftViewModel.aircraft?.videoTxType.title
        case .videoTxPower:
            return aircraftViewModel.aircraft?.videoTxPower?.title
        case .videoTxChannels:
            return aircraftViewModel.aircraft?.videoTxChannels.title
        case .videoRxChannels:
            return aircraftViewModel.aircraft?.videoRxChannels?.title
        case .antenna:
            return aircraftViewModel.aircraft?.antenna.title
        }
    }

    // MARK: - Button Events

    @objc func didPressDeleteButton() {
        ActionSheetUtil.presentDestructiveActionSheet(withTitle: "Are you sure you want to delete to \"\(aircraftViewModel.displayName)\"?", destructiveTitle: "Yes, delete", completion: { (action) in
            self.deleteAircraft()
        }, cancel: nil)
    }

    func deleteAircraft() {
        let aircraftId = aircraftViewModel.aircraftId

        aircraftApi.delete(aircraft: aircraftId) { [weak self] (status, error)  in
            guard let strongSelf = self else { return }
            if status {
                strongSelf.delegate?.aircraftDetailViewController(strongSelf, didDeleteAircraft: aircraftId)
            } else if let _ = error {
                //
            }
        }
    }
}

extension AircraftDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let row = AircraftRow(rawValue: indexPath.row) else { return }

        presentPicker(forRow: row)
        selectedRow = row
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

extension AircraftDetailViewController: PickerViewControllerDelegate {

    func pickerViewController(_ viewController: PickerViewController, didSelectItem item: String) {
        guard let row = selectedRow else { return }

        let specs = AircraftSpecs()

        switch row {
        case .type:
            let type = AircraftType(title: item)
            specs.type = type?.rawValue
        case .size:
            let type = AircraftSize(title: item)
            specs.size = type?.rawValue
        case .battery:
            let type = BatterySize(title: item)
            specs.battery = type?.rawValue
        case .propSize:
            let type = PropellerSize(title: item)
            specs.propSize = type?.rawValue
        case .videoTx:
            let type = VideoTxType(title: item)
            specs.videoTxType = type?.rawValue
        case .videoTxPower:
            let type = VideoTxPower(title: item)
            specs.videoTxPower = type?.rawValue
        case .videoTxChannels:
            let type = VideoChannels(title: item)
            specs.videoTxChannels = type?.rawValue
        case .videoRxChannels:
            let type = VideoChannels(title: item)
            specs.videoRxChannels = type?.rawValue
        case .antenna:
            let type = AntennaPolarization(title: item)
            specs.antenna = type?.rawValue
        }

        aircraftApi.update(aircraft: aircraftViewModel.aircraftId, with: specs) { (status, error) in
            if status {
                // handle success
            } else if let _ = error {
                // handle failure
            }

            viewController.dismiss(animated: true, completion: nil)
        }
    }

    func pickerViewControllerDidDismiss(_ viewController: PickerViewController) {
        //
    }
}

// MARK: - ScrollView Delegate

extension AircraftDetailViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        stretchHeaderView(with: scrollView.contentOffset)
    }
}

// MARK: - HeaderStretchable

extension AircraftDetailViewController: HeaderStretchable {

    var targetHeaderView: UIView {
        return headerView.backgroundImageView
    }

    var targetHeaderViewSize: CGSize {
        return headerView.backgroundImageViewSize
    }

    var topLayoutInset: CGFloat {
        return topOffset
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
