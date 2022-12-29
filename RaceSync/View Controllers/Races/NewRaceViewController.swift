//
//  NewRaceViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2022-12-26.
//  Copyright © 2022 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI
import SnapKit
import UIKit

class NewRaceViewController: UIViewController {

    // MARK: - Public Variables

    var subtitle: String?

    var chapters: [ManagedChapter]

    // MARK: - Private Variables

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(cellType: FormTableViewCell.self)
        tableView.contentInsetAdjustmentBehavior = .always
        tableView.tableHeaderView = nil
        tableView.tableFooterView = footerView
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()

    fileprivate lazy var headerView: UIView = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = subtitle
        label.textColor = Color.gray200

        let view = UIView()
        view.backgroundColor = .clear
        view.addSubview(label)
        label.snp.makeConstraints {
            $0.height.equalTo(Constants.cellHeight)
            $0.bottom.leading.equalToSuperview().offset(Constants.padding)
            $0.trailing.equalToSuperview().offset(-Constants.padding)
        }

        return view
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

    fileprivate lazy var rightBarButtonItem: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(didPressNextButton))
        barButtonItem.isEnabled = false
        return barButtonItem
    }()

    fileprivate var raceData: RaceData
    fileprivate var selectedRow: NewRaceRow?
    fileprivate var raceApi = RaceApi()

    fileprivate var isFormEnabled: Bool = true

    fileprivate let presenter = Appearance.defaultPresenter()
    fileprivate var formNavigationController: NavigationController?

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = 50
    }

    // MARK: - Initialization

    init(with chapters: [ManagedChapter], selectedChapter: ManagedChapter?) {
        self.chapters = chapters

        self.raceData = RaceData()
        self.raceData.chapterName = selectedChapter?.name
        self.raceData.chapterId = selectedChapter?.id
        self.raceData.class = NewRaceRow.class.defaultValue
        self.raceData.format = NewRaceRow.format.defaultValue
        self.raceData.schedule = NewRaceRow.schedule.defaultValue
        self.raceData.privacy = NewRaceRow.privacy.defaultValue
        self.raceData.status = NewRaceRow.status.defaultValue

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

        if isFormEnabled {
            DispatchQueue.main.async { [weak self] in
                let row = NewRaceRow.name
                self?.presentTextField(forRow: row)
                self?.selectedRow = row
            }
        }
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        title = "New Event"
        subtitle = "General Event Details"

        view.backgroundColor = Color.white
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationItem.rightBarButtonItem?.isEnabled = canGoNextStep()

        if navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: ButtonImg.close, style: .done, target: self, action: #selector(didPressCloseButton))
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - Actions

    @objc func didPressNextButton() {

        // Move to next step

//        isLoading = true

//        aircraftAPI.createAircraft(with: aircraftData) { [weak self] (aircraft, error) in
//            guard let strongSelf = self else { return }
//            if let aircraft = aircraft {
//                strongSelf.delegate?.newAircraftViewController(strongSelf, didCreateAircraft: aircraft)
//
//                RateMe.sharedInstance.userDidPerformEvent(showPrompt: true)
//            } else if let error = error {
//                AlertUtil.presentAlertMessage(error.localizedDescription, title: "Error")
//            }
//
//            strongSelf.isLoading = false
//        }
    }

    @objc fileprivate func didPressCloseButton() {
//        delegate?.newAircraftViewControllerDidDismiss(self)
        dismiss(animated: true)
    }
}

extension NewRaceViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let row = NewRaceRow(rawValue: indexPath.row) else { return }
        selectedRow = row

        if row == .name {
            presentTextField(forRow: row)
        } else if row == .date {
            presentDatePicker(forRow: row)
        } else {
            presentTextPicker(forRow: row)
        }
    }
}

extension NewRaceViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return NewRaceRow.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as FormTableViewCell
        guard let row = NewRaceRow(rawValue: indexPath.row) else { return cell }

        if row.isRowRequired {
            cell.textLabel?.text = row.title + " *"
        } else {
            cell.textLabel?.text = row.title
        }

        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = Color.black

        cell.detailTextLabel?.text = row.displayText(from: raceData)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = Color.gray300

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }

//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return subtitle
//    }
//
//    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
//        return "* Required fields"
//    }
}

fileprivate extension NewRaceViewController {

    func presentTextField(forRow row: NewRaceRow, animated: Bool = true) {

        let textFieldVC = TextFieldViewController(with: raceData.name)
        textFieldVC.delegate = self
        textFieldVC.title = row.title
        textFieldVC.textField.placeholder = row.title

        let formdNC = NavigationController(rootViewController: textFieldVC)
        customPresentViewController(presenter, viewController: formdNC, animated: animated)

        formNavigationController = formdNC
    }

    func presentTextPicker(forRow row: NewRaceRow, animated: Bool = true) {
        let pickerVC = textPickerViewController(for: row)
        let formdNC = NavigationController(rootViewController: pickerVC)
        customPresentViewController(presenter, viewController: formdNC, animated: animated)
    }

    func pushTextPicker(forRow row: NewRaceRow, animated: Bool = true) {
        let pickerVC = textPickerViewController(for: row)
        formNavigationController?.pushViewController(pickerVC, animated: animated)
        formNavigationController?.delegate = self
    }

    func presentDatePicker(forRow row: NewRaceRow, animated: Bool = true) {
        let pickerVC = DatePickerViewController(with: StandardDateTimeFormat)
        pickerVC.title = row.title
        pickerVC.delegate = self

        let formdNC = NavigationController(rootViewController: pickerVC)
        customPresentViewController(presenter, viewController: formdNC, animated: animated)
    }

    func pushDatePicker(forRow row: NewRaceRow, animated: Bool = true) {
        let pickerVC = DatePickerViewController(with: StandardDateTimeFormat)
        pickerVC.title = row.title
        pickerVC.delegate = self

        formNavigationController?.pushViewController(pickerVC, animated: animated)
        formNavigationController?.delegate = self
    }

    func textPickerViewController(for row: NewRaceRow) -> TextPickerViewController {
        let items = values(for: row)

        let selectedItem = row.displayText(from: raceData)
        let defaultItem = row.defaultValue

        let pickerVC = TextPickerViewController(with: items, selectedItem: selectedItem, defaultItem: defaultItem)
        pickerVC.delegate = self
        pickerVC.title = row.title

        return pickerVC
    }

    func values(for row: NewRaceRow) -> [String] {
        switch row {
        case .chapter:
            return chapters.compactMap { $0.name }
        case .class:
            return RaceClass.allCases.compactMap { $0.title }
        case .format:
            return ScoringFormats.allCases.compactMap { $0.title }
        case .schedule:
            return RaceSchedule.allCases.compactMap { $0.rawValue }
        case .privacy:
            return EventType.allCases.compactMap { $0.title }
        case .status:
            return RaceStatus.allCases.compactMap { $0.title }
        default:
            return [String]()
        }
    }

    // MARK: - Verification

    func canGoNextStep() -> Bool {
        let requiredRows = NewRaceRow.allCases.filter({ (row) -> Bool in
            return row.isRowRequired
        })

        for row in requiredRows {
            if let value = row.value(from: raceData) {
                if value.isEmpty { return false }
            } else {
                return false
            }
        }

        return true
    }
}

// MARK: - TextFieldViewController Delegate

extension NewRaceViewController: FormBaseViewControllerDelegate {

    func formViewController(_ viewController: FormBaseViewController, didSelectItem item: String) {
        guard let currentRow = selectedRow else { return }

        if viewController.formType == .textfield {
            handleTextfieldVC(viewController, selection: item)
        } else if viewController.formType == .textPicker {
            handleTextPickerVC(viewController, selection: item)
        } else if viewController.formType == .datepicker {
            handleDatePickerVC(viewController, selection: item)
        }

        if !item.isEmpty {
            tableView.reloadData()
            navigationItem.rightBarButtonItem?.isEnabled = canGoNextStep()
        }

        // invalidate form once reaching the end of it
        if isFormEnabled, currentRow.rawValue == NewRaceRow.allCases.count-1 {
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
            guard item.count >= Race.nameMinLength else { return false }
            guard item.count < Race.nameMaxLength else { return false }
        }

        if currentRow.isRowRequired {
            return !item.isEmpty
        }

        return true
    }

    func formViewControllerRightBarButtonTitle(_ viewController: FormBaseViewController) -> String {
        guard let currentRow = selectedRow else { return "" }

        if isFormEnabled, currentRow.rawValue != NewRaceRow.allCases.count-1 {
            return "Next"
        }
        return "OK"
    }

    func formViewControllerKeyboardReturnKeyType(_ viewController: FormBaseViewController) -> UIReturnKeyType {
        return isFormEnabled ? .next : .done
    }

    func handleTextfieldVC(_ viewController: FormBaseViewController, selection item: String) {
        raceData.name = item

        if isFormEnabled {
            let row = NewRaceRow.date
            pushDatePicker(forRow: row, animated: true)
            selectedRow = row
        } else {
            viewController.dismiss(animated: true)
        }
    }

    func handleTextPickerVC(_ viewController: FormBaseViewController, selection item: String) {
        guard let currentRow = selectedRow else { return }

        switch currentRow {
        case .chapter:
            let chapter = chapters.filter ({ return $0.name == item }).first
            raceData.chapterName = chapter?.name
            raceData.chapterId = chapter?.id
        case .class:
            raceData.class = RaceClass(title: item)?.rawValue
        case .format:
            raceData.format = ScoringFormats(title: item)?.rawValue
        case .schedule:
            raceData.schedule = item
        case .privacy:
            raceData.privacy = EventType(title: item)?.rawValue
        case .status:
            raceData.status = item
        default:
            break
        }

        if isFormEnabled, let nextRow = NewRaceRow(rawValue: currentRow.rawValue + 1) {
            pushTextPicker(forRow: nextRow, animated: true)
            selectedRow = nextRow
        } else {
            viewController.dismiss(animated: true)
        }
    }

    func handleDatePickerVC(_ viewController: FormBaseViewController, selection item: String) {
        raceData.date = item

        if isFormEnabled {
            let row = NewRaceRow.chapter
            pushTextPicker(forRow: row, animated: true)
            selectedRow = row
        } else {
            viewController.dismiss(animated: true)
        }
    }
}

// MARK: - TextPickerViewController Delegate

extension NewRaceViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let currentRow = selectedRow else { return nil }

        if operation == .pop {
            selectedRow = NewRaceRow(rawValue: currentRow.rawValue - 1)
        }

        return nil
    }
}
