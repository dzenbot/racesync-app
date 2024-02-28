//
//  AircraftFormViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-02-22.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import RaceSyncAPI
import Presentr

protocol AircraftFormViewControllerDelegate {
    func aircraftFormViewController(_ viewController: AircraftFormViewController, didCreateAircraft aircraft: Aircraft)
    func aircraftFormViewControllerDidDismiss(_ viewController: AircraftFormViewController)
    func aircraftFormViewController(_ viewController: AircraftFormViewController, valuesFor row: AircraftFormRow) -> [String]?
}

class AircraftFormViewController: UIViewController {

    var delegate: AircraftFormViewControllerDelegate?

    // MARK: - Private Variables

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(cellType: FormTableViewCell.self)
        tableView.contentInsetAdjustmentBehavior = .always
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self

        let backgroundView = UIView()
        backgroundView.backgroundColor = Color.gray20
        tableView.backgroundView = backgroundView

        return tableView
    }()

    fileprivate var isLoading: Bool = false {
        didSet {
            if isLoading {
                navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicatorView)
                activityIndicatorView.startAnimating()
            }
            else {
                navigationItem.rightBarButtonItem = rightBarButtonItem
                activityIndicatorView.stopAnimating()
            }
        }
    }

    fileprivate lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        return view
    }()

    fileprivate lazy var rightBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didPressSaveButton))
        barButtonItem.isEnabled = false
        return barButtonItem
    }()

    fileprivate var aircraftAPI = AircraftApi()
    fileprivate var aircraftData = AircraftData()
    fileprivate var selectedRow: AircraftFormRow?
    fileprivate var isFormEnabled: Bool = true

    fileprivate let presenter = Appearance.defaultPresenter()
    fileprivate var formNavigationController: NavigationController?

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = 56
    }

    // MARK: - Initialization

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    init(with aircraftData: AircraftData) {
        self.aircraftData = aircraftData
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
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

        if isFormEnabled {
            DispatchQueue.main.async { [weak self] in
                let row = AircraftFormRow.name
                self?.presentTextField(forRow: row)
                self?.selectedRow = row
            }
        }
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        title = "New Aircraft"
        view.backgroundColor = Color.white
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.rightBarButtonItem?.isEnabled = canCreateAircraft()

        if let nc = navigationController, nc.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: ButtonImg.close, style: .done, target: self, action: #selector(didPressCloseButton))
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - Action

    @objc func didPressSaveButton() {

        isLoading = true

        aircraftAPI.createAircraft(with: aircraftData) { [weak self] (aircraft, error) in
            guard let strongSelf = self else { return }
            if let aircraft = aircraft {
                strongSelf.delegate?.aircraftFormViewController(strongSelf, didCreateAircraft: aircraft)

                RateMe.sharedInstance.userDidPerformEvent(showPrompt: true)
            } else if let error = error {
                AlertUtil.presentAlertMessage(error.localizedDescription, title: "Error")
            }

            strongSelf.isLoading = false
        }
    }

    @objc func didPressCloseButton() {
        delegate?.aircraftFormViewControllerDidDismiss(self)
    }
}

fileprivate extension AircraftFormViewController {

    func presentTextField(forRow row: AircraftFormRow, animated: Bool = true) {

        let vc = TextFieldViewController(with: aircraftData.name)
        vc.delegate = self
        vc.title = row.title
        vc.textField.placeholder = row.title

        let nc = NavigationController(rootViewController: vc)
        customPresentViewController(presenter, viewController: nc, animated: animated)

        formNavigationController = nc
    }

    func presentPicker(forRow row: AircraftFormRow, animated: Bool = true) {
        let vc = textPickerViewController(for: row)
        let nc = NavigationController(rootViewController: vc)
        customPresentViewController(presenter, viewController: nc, animated: animated)
    }

    func pushPicker(forRow row: AircraftFormRow, animated: Bool = true) {
        let vc = textPickerViewController(for: row)
        formNavigationController?.pushViewController(vc, animated: animated)
        formNavigationController?.delegate = self
    }

    func textPickerViewController(for row: AircraftFormRow) -> TextPickerViewController {
        var items = row.values
        if let values = delegate?.aircraftFormViewController(self, valuesFor: row) {
            items = values
        }

        let selectedItem = row.displayText(from: aircraftData) ?? row.defaultValue

        let vc = TextPickerViewController(with: items, selectedItem: selectedItem)
        vc.delegate = self
        vc.title = row.title
        return vc
    }

    func showAircraftDetail(_ aircraftViewModel: AircraftViewModel) {
        let vc = AircraftDetailViewController(with: aircraftViewModel)
        vc.isEditable = true

        vc.willMove(toParent: navigationController)
        navigationController?.addChild(vc)

        vc.view.frame = self.view.frame
        navigationController?.view.addSubview(vc.view)

        vc.didMove(toParent: navigationController)

        self.view.removeFromSuperview()
        navigationController?.removeFromParent()
    }

    // MARK: - Verification

    func canCreateAircraft() -> Bool {
        let requiredRows = AircraftFormRow.allCases.filter({ (row) -> Bool in
            return row.isRowRequired
        })

        for row in requiredRows {
            if let value = row.value(from: aircraftData) {
                if value.isEmpty { return false }
            } else {
                return false
            }
        }

        return true
    }
}

extension AircraftFormViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let row = AircraftFormRow(rawValue: indexPath.row) else { return }

        if row == .name {
            presentTextField(forRow: row)
        } else {
            presentPicker(forRow: row)
        }

        selectedRow = row
    }
}

extension AircraftFormViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AircraftFormRow.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as FormTableViewCell
        guard let row = AircraftFormRow(rawValue: indexPath.row) else { return cell }

        if row.isRowRequired {
            cell.textLabel?.text = row.title + " *"
        } else {
            cell.textLabel?.text = row.title
        }

        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = Color.black

        cell.detailTextLabel?.text = row.displayText(from: aircraftData)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = Color.gray300

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "* Required fields"
    }
}

// MARK: - TextFieldViewController Delegate

extension AircraftFormViewController: FormBaseViewControllerDelegate {

    func formViewController(_ viewController: FormBaseViewController, didSelectItem item: String) {
        guard let currentRow = selectedRow else { return }

        if viewController.formType == .textfield {
            handleTextfieldVC(viewController, selection: item)
        } else if viewController.formType == .textPicker {
            handleTextPickerVC(viewController, selection: item)
        }

        if !item.isEmpty {
            tableView.reloadData()
            navigationItem.rightBarButtonItem?.isEnabled = canCreateAircraft()
        }

        // invalidate form once reaching the end of it
        if isFormEnabled, currentRow.rawValue == AircraftFormRow.allCases.count-1 {
            isFormEnabled = false
            selectedRow = nil
        }
    }

    func formViewControllerDidDismiss(_ viewController: FormBaseViewController) {
        isFormEnabled = false
        selectedRow = nil
    }

    func formViewController(_ viewController: FormBaseViewController, enableSelectionWithItem item: String) -> Bool {
        guard let currentRow = selectedRow else { return false }

        if viewController is TextFieldViewController {
            guard item.count >= Aircraft.nameMinLength else { return false }
            guard item.count < Aircraft.nameMaxLength else { return false }
        }

        if !isFormEnabled && currentRow.isRowRequired {
            return !item.isEmpty
        }

        return true
    }

    func formViewControllerRightBarButtonTitle(_ viewController: FormBaseViewController) -> String {
        guard let currentRow = selectedRow else { return "" }

        if isFormEnabled, currentRow.rawValue != AircraftFormRow.allCases.count-1 {
            return "Next"
        }
        return "OK"
    }

    func formViewControllerKeyboardReturnKeyType(_ viewController: FormBaseViewController) -> UIReturnKeyType {
        return isFormEnabled ? .next : .done
    }

    func handleTextfieldVC(_ viewController: FormBaseViewController, selection item: String) {
        aircraftData.name = item

        if isFormEnabled {
            let row = AircraftFormRow.type
            pushPicker(forRow: row, animated: true)
            selectedRow = row
        } else {
            viewController.dismiss(animated: true)
        }
    }

    func handleTextPickerVC(_ viewController: FormBaseViewController, selection item: String) {
        guard let currentRow = selectedRow else { return }

        switch currentRow {
        case .type:
            let type = AircraftType(title: item)
            aircraftData.type = type?.rawValue
        case .size:
            let type = AircraftSize(title: item)
            aircraftData.size = type?.rawValue
        case .battery:
            let type = BatterySize(title: item)
            aircraftData.battery = type?.rawValue
        case .propSize:
            let type = PropellerSize(title: item)
            aircraftData.propSize = type?.rawValue
        case .videoTx:
            let type = VideoTxType(title: item)
            aircraftData.videoTxType = type?.rawValue
        case .antenna:
            let type = AntennaPolarization(title: item)
            aircraftData.antenna = type?.rawValue
        default:
            break
        }

        if isFormEnabled, let nextRow = AircraftFormRow(rawValue: currentRow.rawValue + 1) {
            pushPicker(forRow: nextRow, animated: true)
            selectedRow = nextRow
        } else {
            viewController.dismiss(animated: true)
        }
    }
}

// MARK: - TextPickerViewController Delegate

extension AircraftFormViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let currentRow = selectedRow else { return nil }

        if operation == .pop {
            selectedRow = AircraftFormRow(rawValue: currentRow.rawValue - 1)
        }

        return nil
    }
}
