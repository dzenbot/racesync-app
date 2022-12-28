//
//  NewAircraftViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-02-22.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import RaceSyncAPI
import Presentr

protocol NewAircraftViewControllerDelegate {
    func newAircraftViewController(_ viewController: NewAircraftViewController, didCreateAircraft aircraft: Aircraft)
    func newAircraftViewControllerDidDismiss(_ viewController: NewAircraftViewController)
    func newAircraftViewController(_ viewController: NewAircraftViewController, valuesFor row: AircraftRow) -> [String]?
}

class NewAircraftViewController: UIViewController {

    var delegate: NewAircraftViewControllerDelegate?

    // MARK: - Private Variables

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(cellType: FormTableViewCell.self)
        tableView.contentInsetAdjustmentBehavior = .always
        tableView.tableFooterView = footerView
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    fileprivate lazy var footerView: UIView = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = "* Required fields"
        label.textColor = Color.gray200

        let view = UIView()
        view.backgroundColor = .clear
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.height.equalTo(Constants.cellHeight)
            $0.top.leading.equalToSuperview().offset(Constants.padding)
            $0.trailing.equalToSuperview().offset(-Constants.padding)
        }

        return view
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
    fileprivate var selectedRow: AircraftRow?
    fileprivate var isFormEnabled: Bool = true

    fileprivate let presenter = Appearance.defaultPresenter()
    fileprivate var formNavigationController: NavigationController?

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = 50
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
                let row = AircraftRow.name
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
                strongSelf.delegate?.newAircraftViewController(strongSelf, didCreateAircraft: aircraft)

                RateMe.sharedInstance.userDidPerformEvent(showPrompt: true)
            } else if let error = error {
                AlertUtil.presentAlertMessage(error.localizedDescription, title: "Error")
            }

            strongSelf.isLoading = false
        }
    }

    @objc func didPressCloseButton() {
        delegate?.newAircraftViewControllerDidDismiss(self)
    }
}

fileprivate extension NewAircraftViewController {

    func presentTextField(forRow row: AircraftRow, animated: Bool = true) {

        let textFieldVC = TextFieldViewController(with: aircraftData.name)
        textFieldVC.delegate = self
        textFieldVC.title = row.title
        textFieldVC.textField.placeholder = row.title

        let formdNC = NavigationController(rootViewController: textFieldVC)
        customPresentViewController(presenter, viewController: formdNC, animated: animated)

        formNavigationController = formdNC
    }

    func presentPicker(forRow row: AircraftRow, animated: Bool = true) {
        let pickerVC = textPickerViewController(for: row)
        let formdNC = NavigationController(rootViewController: pickerVC)
        customPresentViewController(presenter, viewController: formdNC, animated: animated)
    }

    func pushPicker(forRow row: AircraftRow, animated: Bool = true) {
        let pickerVC = textPickerViewController(for: row)
        formNavigationController?.pushViewController(pickerVC, animated: animated)
        formNavigationController?.delegate = self
    }

    func textPickerViewController(for row: AircraftRow) -> TextPickerViewController {
        var items = row.values
        if let values = delegate?.newAircraftViewController(self, valuesFor: row) {
            items = values
        }

        let selectedItem = row.displayText(from: aircraftData)
        let defaultItem = row.defaultValue

        let pickerVC = TextPickerViewController(with: items, selectedItem: selectedItem, defaultItem: defaultItem)
        pickerVC.delegate = self
        pickerVC.title = row.title

        return pickerVC
    }

    func showAircraftDetail(_ aircraftViewModel: AircraftViewModel) {
        let aircraftDetailVC = AircraftDetailViewController(with: aircraftViewModel)
        aircraftDetailVC.isEditable = true

        aircraftDetailVC.willMove(toParent: navigationController)
        navigationController?.addChild(aircraftDetailVC)

        aircraftDetailVC.view.frame = self.view.frame
        navigationController?.view.addSubview(aircraftDetailVC.view)

        aircraftDetailVC.didMove(toParent: navigationController)

        self.view.removeFromSuperview()
        navigationController?.removeFromParent()
    }

    // MARK: - Verification

    func canCreateAircraft() -> Bool {
        let requiredRows = AircraftRow.allCases.filter({ (row) -> Bool in
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

extension NewAircraftViewController: UITableViewDelegate {

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

extension NewAircraftViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AircraftRow.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as FormTableViewCell
        guard let row = AircraftRow(rawValue: indexPath.row) else { return cell }

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
}

// MARK: - TextFieldViewController Delegate

extension NewAircraftViewController: FormBaseViewControllerDelegate {

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
        if isFormEnabled, currentRow.rawValue == AircraftRow.allCases.count-1 {
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

        if isFormEnabled, currentRow.rawValue != AircraftRow.allCases.count-1 {
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
            let row = AircraftRow.type
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

        if isFormEnabled, let nextRow = AircraftRow(rawValue: currentRow.rawValue + 1) {
            pushPicker(forRow: nextRow, animated: true)
            selectedRow = nextRow
        } else {
            viewController.dismiss(animated: true)
        }
    }
}

// MARK: - TextPickerViewController Delegate

extension NewAircraftViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let currentRow = selectedRow else { return nil }

        if operation == .pop {
            selectedRow = AircraftRow(rawValue: currentRow.rawValue - 1)
        }

        return nil
    }
}
