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
    func aircraftDetailViewController(_ viewController: AircraftDetailViewController, didEditAircraft aircraftId: ObjectId)
    func aircraftDetailViewController(_ viewController: AircraftDetailViewController, didDeleteAircraft aircraftId: ObjectId)
}

class AircraftDetailViewController: UIViewController {

    let shouldDisplayHeader: Bool = true

    // MARK: - Public Variables

    var delegate: AircraftDetailViewControllerDelegate?

    // MARK: - Private Variables

    fileprivate let headerView = ProfileHeaderView()

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.identifier)
        tableView.contentInsetAdjustmentBehavior = .always
        tableView.tableFooterView = UIView()
        return tableView
    }()

    fileprivate lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.hidesWhenStopped = true
        return view
    }()

    var isLoading: Bool = false {
        didSet {
            if isLoading { activityIndicatorView.startAnimating() }
            else { activityIndicatorView.stopAnimating() }
        }
    }

    fileprivate var topOffset: CGFloat {
        get {
            let status_height = UIApplication.shared.statusBarFrame.height
            let navi_height = navigationController?.navigationBar.frame.size.height ?? 44
            return status_height + navi_height
        }
    }

    fileprivate var aircraftViewModel: AircraftViewModel {
        didSet { navigationItem.title = aircraftViewModel.displayName }
    }
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
        
        setupLayout()
        isLoading = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        isLoading = false
        tableView.reloadData()
    }

    // MARK: - Layout

    func setupLayout() {
        guard let aircraft = aircraftViewModel.aircraft else { return }

        navigationItem.title = aircraftViewModel.displayName
        view.backgroundColor = Color.white

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(didPressDeleteButton))
        navigationItem.rightBarButtonItem?.tintColor = Color.red

        headerView.topLayoutInset = topOffset
        headerView.viewModel = ProfileViewModel(with: aircraft)
        tableView.tableHeaderView = headerView

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }

        let headerViewSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        headerView.snp.makeConstraints {
            $0.size.equalTo(headerViewSize)
        }

        view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }

    fileprivate func presentPicker(forRow row: AircraftRow) {
        let items = row.aircraftSpecValues
        let selectedItem = row.specValue(from: aircraftViewModel)
        let defaultItem = row.defaultAircraftSpecValue

        let presenter = Appearance.defaultPresenter()
        let pickerVC = PickerViewController(with: items, selectedItem: selectedItem, defaultItem: defaultItem)
        pickerVC.delegate = self
        pickerVC.title = "Update \(row.title)"

        let formdNC = NavigationController(rootViewController: pickerVC)
        customPresentViewController(presenter, viewController: formdNC, animated: true)
    }

    fileprivate func presentTextField(forRow row: AircraftRow) {
        let text = row.specValue(from: aircraftViewModel)

        let presenter = Appearance.defaultPresenter()
        let textFieldVC = TextFieldViewController(with: text)
        textFieldVC.delegate = self
        textFieldVC.title = "Update \(row.title)"
        textFieldVC.textField.placeholder = "Aircraft Name"

        let formdNC = NavigationController(rootViewController: textFieldVC)
        customPresentViewController(presenter, viewController: formdNC, animated: true)
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

        if row == .name {
            presentTextField(forRow: row)
        } else {
            presentPicker(forRow: row)
        }

        selectedRow = row
    }
}

extension AircraftDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isLoading ? 0 : AircraftRow.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTableViewCell.identifier) as! FormTableViewCell
        guard let row = AircraftRow(rawValue: indexPath.row) else { return cell }

        if row.isAircraftSpecRequired {
            cell.textLabel?.text = row.title + " *"
        } else {
            cell.textLabel?.text = row.title
        }

        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = Color.black

        cell.detailTextLabel?.text = row.displayText(from: aircraftViewModel)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = Color.gray300

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
}

// MARK: - TextFieldViewController Delegate

extension AircraftDetailViewController: FormViewControllerDelegate {

    func formViewController(_ viewController: FormViewController, didSelectItem item: String) {

        if viewController.formType == .textfield {
            handleTextfieldVC(viewController, selection: item)
        } else if viewController.formType == .picker {
            handlePickerVC(viewController, selection: item)
        }
    }

    func formViewController(_ viewController: FormViewController, enableSelectionWithItem item: String) -> Bool {
        guard let row = selectedRow else { return false }

        if row.isAircraftSpecRequired {
            return !item.isEmpty
        }

        return true
    }

    func formViewControllerDidDismiss(_ viewController: FormViewController) {
        //
    }

    func handleTextfieldVC(_ viewController: FormViewController, selection item: String) {
        guard let aircraft = aircraftViewModel.aircraft else { return }

        let specs = AircraftSpecs()
        specs.name = item
        aircraft.name = item

        viewController.isLoading = true

        aircraftApi.update(aircraft: aircraftViewModel.aircraftId, with: specs) {  [weak self] (status, error) in
            guard let strongSelf = self else { return }
            if status {
                strongSelf.aircraftViewModel = AircraftViewModel(with: aircraft)
                strongSelf.tableView.reloadData()
                strongSelf.delegate?.aircraftDetailViewController(strongSelf, didEditAircraft: aircraft.id)
            } else if let _ = error {
                viewController.isLoading = false
                // present dialog?
            }

            viewController.dismiss(animated: true, completion: nil)
        }
    }

    func handlePickerVC(_ viewController: FormViewController, selection item: String) {
        guard let row = selectedRow else { return }
        guard let aircraft = aircraftViewModel.aircraft else { return }

        let specs = AircraftSpecs()

        switch row {
        case .type:
            let type = AircraftType(title: item)
            specs.type = type?.rawValue
            aircraft.type = type
        case .size:
            let type = AircraftSize(title: item)
            specs.size = type?.rawValue
            aircraft.size = type
        case .battery:
            let type = BatterySize(title: item)
            specs.battery = type?.rawValue
            aircraft.battery = type
        case .propSize:
            let type = PropellerSize(title: item)
            specs.propSize = type?.rawValue
            aircraft.propSize = type
        case .videoTx:
            let type = VideoTxType(title: item)
            specs.videoTxType = type?.rawValue
            aircraft.videoTxType = type ?? .´5800mhz´
        case .videoTxPower:
            let type = VideoTxPower(title: item)
            specs.videoTxPower = type?.rawValue
            aircraft.videoTxPower = type
        case .videoTxChannels:
            let type = VideoChannels(title: item)
            specs.videoTxChannels = type?.rawValue
            aircraft.videoTxChannels = type ?? .raceband40
        case .videoRxChannels:
            let type = VideoChannels(title: item)
            specs.videoRxChannels = type?.rawValue
            aircraft.videoRxChannels = type
        case .antenna:
            let type = AntennaPolarization(title: item)
            specs.antenna = type?.rawValue
            aircraft.antenna = type ?? .both
        default:
            break
        }

        viewController.isLoading = true

        aircraftApi.update(aircraft: aircraft.id, with: specs) { [weak self] (status, error) in
            guard let strongSelf = self else { return }
            if status {
                strongSelf.aircraftViewModel = AircraftViewModel(with: aircraft)
                strongSelf.tableView.reloadData()
                strongSelf.delegate?.aircraftDetailViewController(strongSelf, didEditAircraft: aircraft.id)
            } else if let _ = error {
                viewController.isLoading = false
                // present dialog?
            }

            viewController.dismiss(animated: true, completion: nil)
        }
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
