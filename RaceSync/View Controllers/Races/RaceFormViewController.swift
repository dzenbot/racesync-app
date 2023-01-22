//
//  RaceFormViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2022-12-26.
//  Copyright © 2022 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI
import SnapKit
import UIKit

protocol RaceFormViewControllerDelegate {
    func raceFormViewController(_ viewController: RaceFormViewController, didUpdateRace race: Race)
    func raceFormViewControllerDidDismiss(_ viewController: RaceFormViewController)
}

class RaceFormViewController: UIViewController {

    // MARK: - Public Variables

    var chapters: [ManagedChapter]
    var editMode: RaceFormMode = .new
    var delegate: RaceFormViewControllerDelegate?

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

    fileprivate lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        return view
    }()

    fileprivate lazy var rightBarButtonItem: UIBarButtonItem = {
        let title = (currentSection == .specific) ? "Save" : "Next"
        let item = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(didPressNextButton))
        item.isEnabled = canGoNextSection()
        return item
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

    fileprivate var data: RaceData
    fileprivate var initialData: RaceData?

    fileprivate var currentSection: RaceFormSection
    fileprivate var selectedRow: RaceFormRow?
    fileprivate var raceApi = RaceApi()
    fileprivate var seasonApi = SeasonApi()
    fileprivate var seasons: [Season]?
    fileprivate var courseApi = CourseApi()
    fileprivate var courses: [Course]?

    fileprivate var isFormEnabled: Bool

    // TODO: Waiting for backend support. See https://github.com/MultiGP/multigp-com/issues/67
    fileprivate var isEndDateEnabled: Bool = true

    // TODO: Waiting for API support. See https://github.com/MultiGP/multigp-com/issues/68
    fileprivate var isNotiticationEnabled: Bool = false

    fileprivate let presenter = Appearance.defaultPresenter()
    fileprivate var formNavigationController: NavigationController?

    fileprivate lazy var sections: [RaceFormSection: [RaceFormRow]] = {

        var general: [RaceFormRow] = [.name, .startDate]
        if isEndDateEnabled {
            general += [.endDate]
        }
        general += [.chapter, .class, .format, .schedule, .privacy, .status]

        var specific: [RaceFormRow] = [.scoring, .timing, .rounds, .season, .location, .shortDesc, .longDesc, .itinerary]
        if isNotiticationEnabled {
            specific += [.notify]
        }

        return [.general: general, .specific: specific]
    }()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = 56
    }

    // MARK: - Initialization

    init(with chapters: [ManagedChapter], selectedChapterId: ObjectId, selectedChapterName: String) {
        self.chapters = chapters
        self.data = RaceData(with: selectedChapterId, chapterName: selectedChapterName)
        self.currentSection = .general
        self.isFormEnabled = true

        super.init(nibName: nil, bundle: nil)
        self.title = "New Event"
    }

    init(with chapters: [ManagedChapter], raceData: RaceData, initialRaceData: RaceData? = nil, section: RaceFormSection = .general) {
        self.chapters = chapters
        self.data = raceData
        self.initialData = initialRaceData
        self.currentSection = section
        self.isFormEnabled = false

        super.init(nibName: nil, bundle: nil)
        self.title = data.name
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

        // Bring up keyboard on first row, if applicable
        if isFormEnabled, currentSection == .general, editMode == .new {
            let rows = currentSectionRows()

            DispatchQueue.main.async { [weak self] in
                if let firstRow = rows?.first, firstRow.formType == .textfield {
                    self?.presentTextField(forRow: firstRow)
                    self?.selectedRow = firstRow
                }
            }
        }
    }

    // MARK: - Layout

    fileprivate func setupLayout() {
        
        view.backgroundColor = Color.white
        navigationItem.rightBarButtonItem = rightBarButtonItem

        // Adds a close button in case of being presented modally
        if navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: ButtonImg.close, style: .done, target: self, action: #selector(didPressCloseButton))
        }

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - Actions

    @objc fileprivate func didChangeSwitchValue(_ sender: UISwitch) {
        guard let rows = currentSectionRows() else { return }
        let row = rows[sender.tag]

        if row == .scoring {
            data.funfly = sender.isOn
        } else if row == .timing {
            data.timing = sender.isOn
        } else if row == .notify {
            data.sendNotification = sender.isOn
        }
    }

    @objc func didPressNextButton() {

        // Move to next step
        if currentSection == .general {
            let nextSection: RaceFormSection = .specific
            let vc = RaceFormViewController(with: chapters, raceData: data, initialRaceData: initialData, section: nextSection)
            vc.editMode = editMode
            vc.delegate = delegate

            navigationController?.pushViewController(vc, animated: true)
        } else if currentSection == .specific {
            switch editMode {
            case .new:      createRace()
            case .update:   editRace()
            }
        } /*else if currentSection == .frequencies {

        }*/
    }

    fileprivate func createRace() {

        isLoading = true

        raceApi.createRace(withData: data) { object, error in
            if let race = object {
                self.delegate?.raceFormViewController(self, didUpdateRace: race)
            } else if let error = error {
                AlertUtil.presentAlertMessage("Failed to create the race. Please try again later. \(error.localizedDescription)", title: "Error", delay: 0.5)
                self.isLoading = false
            }
        }
    }

    fileprivate func editRace() {
        guard let id = data.raceId else { return }

        isLoading = true

        raceApi.updateRace(race: id, with: initialData, afterData: data) { object, error in
            if let race = object {
                self.delegate?.raceFormViewController(self, didUpdateRace: race)
            } else if let error = error {
                AlertUtil.presentAlertMessage("Failed to update the race. Please try again later. \(error.localizedDescription)", title: "Error", delay: 0.5)
                self.isLoading = false
            }
        }
    }

    @objc fileprivate func didPressCloseButton() {
        delegate?.raceFormViewControllerDidDismiss(self)
    }
}

extension RaceFormViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let rows = currentSectionRows() else { return }
        guard let cell = tableView.cellForRow(at: indexPath) as? FormTableViewCell else { return }

        let row = rows[indexPath.row]

        if row.formType != .undefined {
            selectedRow = row
        }

        if row.formType == .textfield {
            presentTextField(forRow: row)
        } else if row.formType == .datePicker {
            presentDatePicker(forRow: row)
        } else if row.formType == .textPicker {
            if row == .season {
                presentRaceSeasonPicker(for: row, cell: cell)
            } else if row == .location {
                presentRaceCoursePicker(for: row, cell: cell)
            } else {
                presentTextPicker(forRow: row)
            }
        } else if row.formType == .textEditor {
            pushTextViewController(forRow: row)
        }
    }
}

extension RaceFormViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIdx: Int) -> Int {
        guard let rows = currentSectionRows() else { return 0 }
        return rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as FormTableViewCell
        guard let rows = currentSectionRows() else { return cell }

        let row = rows[indexPath.row]
        let rowValue = row.value(from: data)

        if row.isRowRequired {
            cell.textLabel?.text = row.title + " *"
        } else {
            cell.textLabel?.text = row.title
        }

        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.textLabel?.textColor = Color.black

        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        cell.detailTextLabel?.textColor = Color.gray300

        if row.formType == .switch {
            let accessory = UISwitch()
            accessory.tag = currentSectionRows()?.firstIndex(of: row) ?? 0
            accessory.addTarget(self, action: #selector(didChangeSwitchValue(_:)), for: .valueChanged)
            accessory.isOn = (rowValue != nil)
            cell.accessoryView = accessory
            cell.detailTextLabel?.text = nil
        } else {
            cell.detailTextLabel?.text = rowValue
            cell.accessoryType = .disclosureIndicator
            cell.accessoryView = nil
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return currentSection.header
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return currentSection.footer
    }
}

fileprivate extension RaceFormViewController {

    func presentTextField(forRow row: RaceFormRow, animated: Bool = true) {
        let vc = TextFieldViewController(with: data.name)
        vc.delegate = self
        vc.title = row.title
        vc.textField.placeholder = row.title

        let nc = NavigationController(rootViewController: vc)
        customPresentViewController(presenter, viewController: nc, animated: animated)

        if formNavigationController == nil {
            formNavigationController = nc
        }
    }

    func presentTextPicker(forRow row: RaceFormRow, animated: Bool = true) {
        let vc = textPickerViewController(for: row)
        let nc = NavigationController(rootViewController: vc)
        customPresentViewController(presenter, viewController: nc, animated: animated)

        if formNavigationController == nil {
            formNavigationController = nc
        }
    }

    func presentDatePicker(forRow row: RaceFormRow, animated: Bool = true) {
        let date = date(for: row)
        let vc = DatePickerViewController(with: date)
        vc.title = row.title
        vc.delegate = self

        let nc = NavigationController(rootViewController: vc)
        customPresentViewController(presenter, viewController: nc, animated: animated)

        if formNavigationController == nil {
            formNavigationController = nc
        }
    }

    func pushTextPicker(forRow row: RaceFormRow, animated: Bool = true) {
        let vc = textPickerViewController(for: row)
        formNavigationController?.pushViewController(vc, animated: animated)
        formNavigationController?.delegate = self
    }

    func pushDatePicker(forRow row: RaceFormRow, animated: Bool = true) {
        let date = date(for: row)
        let vc = DatePickerViewController(with: date)
        vc.title = row.title
        vc.delegate = self

        formNavigationController?.pushViewController(vc, animated: animated)
        formNavigationController?.delegate = self
    }

    func textPickerViewController(for row: RaceFormRow) -> TextPickerViewController {
        let values = values(for: row)
        let rowValue = row.value(from: data)
        return textPickerViewController(with: row.title, items: values, selectedItem: rowValue)
    }

    func textPickerViewController(with title: String, items: [String], selectedItem: String? = nil) -> TextPickerViewController {
        let vc = TextPickerViewController(with: items, selectedItem: selectedItem)
        vc.delegate = self
        vc.title = title
        return vc
    }

    func presentRaceSeasonPicker(for row: RaceFormRow, cell: FormTableViewCell) {
        if seasons != nil {
            presentTextPicker(seasons)
        } else {
            cell.isLoading = true

            seasonApi.getSeasons(forChapter: data.chapterId) { seasons, error in
                presentTextPicker(seasons)
                cell.isLoading = false
            }
        }

        func presentTextPicker(_ seasons: [Season]?) {
            guard let seasons = seasons, seasons.count > 0 else { return }

            let names = seasons.compactMap { $0.name }
            self.seasons = seasons

            let vc = textPickerViewController(with: row.title, items: names, selectedItem: data.seasonName)
            let nc = NavigationController(rootViewController: vc)
            customPresentViewController(presenter, viewController: nc, animated: true)
        }
    }

    func presentRaceCoursePicker(for row: RaceFormRow, cell: FormTableViewCell) {
        if courses != nil {
            presentTextPicker(courses)
        } else {
            cell.isLoading = true

            courseApi.getCourses(forChapter: data.chapterId) { courses, error in
                presentTextPicker(courses)
                cell.isLoading = false
            }
        }

        func presentTextPicker(_ courses: [Course]?) {
            guard let courses = courses, courses.count > 0 else { return }

            let names = courses.compactMap { $0.name }
            self.courses = courses

            let vc = textPickerViewController(with: row.title, items: names, selectedItem: data.courseName)
            let nc = NavigationController(rootViewController: vc)
            customPresentViewController(presenter, viewController: nc, animated: true)
        }
    }

    func pushTextViewController(forRow row: RaceFormRow, animated: Bool = true) {

        var text: String?

        if row == .shortDesc {
            text = data.shortDesc
        } else if row == .longDesc {
            text = data.longDesc
        } else if row == .itinerary {
            text = data.itinerary
        }

        let vc = TextEditorViewController(with: text)
        vc.delegate = self
        vc.title = row.title

        navigationController?.pushViewController(vc, animated: animated)
    }

    func values(for row: RaceFormRow) -> [String] {
        switch row {
        case .chapter:
            return chapters.compactMap { $0.name }
        case .class:
            return RaceClass.allCases.compactMap { $0.title }
        case .format:
            return ScoringFormat.allCases.compactMap { $0.title }
        case .schedule:
            return QualifyingType.allCases.compactMap { $0.title }
        case .privacy:
            return EventType.allCases.compactMap { $0.title }
        case .status:
            return RaceStatus.allCases.compactMap { $0.title }
        case .rounds:
            return ["1","2","3","4","5","6","7","8","9","10"]
        default:
            return [String]()
        }
    }

    func date(for row: RaceFormRow) -> Date? {
        if row == .startDate {
            return data.startDate
        } else if row == .endDate {
            if let endDate = data.endDate {
                return endDate
            } else if let startDate = data.startDate {
                // return start date, if already defined, since end date cannot be lower than start date
                return startDate
            }
        }
        return nil
    }

    // MARK: - Verification

    func canGoNextSection() -> Bool {
        for row in currentSectionRequiredRows() {
            if let value = row.requiredValue(from: data) {
                if value.isEmpty { return false }
            } else {
                return false
            }
        }
        return true
    }

    func currentSectionRows() -> [RaceFormRow]? {
        return sections[currentSection]
    }

    func currentSectionRequiredRows() -> [RaceFormRow] {
        guard let rows = currentSectionRows() else { return [RaceFormRow]() }

        return rows.filter({ (row) -> Bool in
            return row.isRowRequired
        })
    }
}

// MARK: - TextFieldViewController Delegate

extension RaceFormViewController: FormBaseViewControllerDelegate {

    func formViewController(_ viewController: FormBaseViewController, didSelectItem item: String) {
        guard let row = selectedRow else { return }

        switch row {
        case .name:
            data.name = item
            title = item
        case .startDate:
            data.startDateString = item
        case .endDate:
            data.endDateString = item
        case .chapter:
            if let chapter = chapters.filter ({ return $0.name == item }).first {
                data.chapterName = chapter.name
                data.chapterId = chapter.id
            }
        case .class:
            if let value = RaceClass(title: item)?.rawValue {
                data.raceClass = value
            }
        case .format:
            if let value = ScoringFormat(title: item)?.rawValue {
                data.format = value
            }
        case .schedule:
            if let value = QualifyingType(title: item)?.rawValue {
                data.qualifying = value
            }
        case .privacy:
            if let value = EventType(title: item)?.rawValue {
                data.privacy = value
            }
        case .status:
            if let value = RaceStatus(title: item)?.rawValue {
                data.status = value
            }
        case .rounds:
            data.rounds = (item as NSString).intValue
        case .season:
            if let season = seasons?.filter ({ return $0.name == item }).first {
                data.seasonId = season.id
                data.seasonName = season.name
            }
        case .location:
            if let course = courses?.filter ({ return $0.name == item }).first {
                data.courseId = course.id
                data.courseName = course.name
            }
        default:
            break
        }

        // refresh content
        if !item.isEmpty {
            tableView.reloadData()
            navigationItem.rightBarButtonItem?.isEnabled = canGoNextSection()
        }

        // handle next row
        if isFormEnabled, let rows = currentSectionRows(), row.rawValue < rows.count-1  {
            guard let nextRow = RaceFormRow(rawValue: row.rawValue + 1) else { return }

            if nextRow.formType == .textPicker {
                selectedRow = nextRow
                pushTextPicker(forRow: nextRow, animated: true)
            } else if nextRow.formType == .datePicker {
                selectedRow = nextRow
                pushDatePicker(forRow: nextRow, animated: true)
            }
        } else {
            formViewControllerDidDismiss(viewController)
        }
    }

    func formViewControllerDidDismiss(_ viewController: FormBaseViewController) {
        // invalidate form once reaching the section
        isFormEnabled = false
        selectedRow = nil

        viewController.dismiss(animated: true)
    }

    func formViewController(_ viewController: FormBaseViewController, enableSelectionWithItem item: String) -> Bool {
        guard let row = selectedRow else { return false }

        if row.formType == .textfield {
            guard item.count >= Race.nameMinLength else { return false }
            guard item.count < Race.nameMaxLength else { return false }
        }

        if row.isRowRequired {
            return !item.isEmpty
        }

        return true
    }

    func formViewControllerRightBarButtonTitle(_ viewController: FormBaseViewController) -> String {
        guard let row = selectedRow, let rows = currentSectionRows() else { return "" }

        if isFormEnabled, row.rawValue < rows.count-1 {
            return "Next"
        }
        return "OK"
    }

    func formViewControllerKeyboardReturnKeyType(_ viewController: FormBaseViewController) -> UIReturnKeyType {
        return isFormEnabled ? .next : .done
    }
}

// MARK: - UINavigationControllerDelegate Delegate

extension RaceFormViewController: TextEditorViewControllerDelegate {

    func textEditorViewController(_ viewController: TextEditorViewController, didEditText text: String) {
        guard let row = selectedRow, row.formType == .textEditor else { return }

        if row == .shortDesc {
            data.shortDesc = text
        } else if row == .longDesc {
            data.longDesc = text
        } else if row == .itinerary {
            data.itinerary = text
        }

        navigationController?.popViewController(animated: true)
        tableView.reloadData()
    }
}

// MARK: - UINavigationControllerDelegate Delegate

extension RaceFormViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let row = selectedRow else { return nil }

        if operation == .pop {
            selectedRow = RaceFormRow(rawValue: row.rawValue - 1)
        }

        return nil
    }
}
