//
//  SettingsViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-18.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import RaceSyncAPI
import Presentr

class SettingsViewController: UIViewController {

    // MARK: - Public Variables

    var promptSearchRadiusPicker: Bool = false

    // MARK: - Private Variables

   fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = headerView
        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.identifier)

        let backgroundView = UIView()
        backgroundView.backgroundColor = Color.gray20
        tableView.backgroundView = backgroundView

        return tableView
    }()

    fileprivate lazy var headerView: UIView = {
        let view = UIView()

        let imageView = UIImageView(image: UIImage(named: "icn_settings_header"))
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-50)
        }

        return view
    }()

    fileprivate let sections: [Section: [Row]] = [
        .search: [.searchRadius, .lengthUnit],
        .about: [.submitFeedback, .readRules, .visitSite],
        .auth: [.logout]
    ]

    fileprivate var selectedRow: Row?

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = 56
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"

        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "icn_navbar_close"), style: .done, target: self, action: #selector(didPressCloseButton))

        setupLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if promptSearchRadiusPicker {
            DispatchQueue.main.async { [weak self] in
                self?.setSearchRadius()
            }
        }
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - Actions

    @objc func didPressCloseButton() {
        dismiss(animated: true, completion: nil)
    }

    fileprivate func setSearchRadius(_ row: Row? = nil) {
        promptSearchRadiusPicker = false
        selectedRow = row

        let radiuses = APIServices.shared.settings.lengthUnit.supportedValues
        let radius = APIServices.shared.settings.searchRadius
        let unit = APIServices.shared.settings.lengthUnit

        let presenter = Appearance.defaultPresenter()
        let pickerVC = PickerViewController(with: radiuses, selectedItem: radius)
        pickerVC.delegate = self
        pickerVC.title = Row.searchRadius.title
        pickerVC.unit = unit.symbol

        let pickerVN = NavigationController(rootViewController: pickerVC)
        
        customPresentViewController(presenter, viewController: pickerVN, animated: true)
    }

    fileprivate func setLengthUnit(_ row: Row? = nil) {
        selectedRow = row

        let units = APIUnitSystem.allCases.compactMap { $0.title }
        let selectedUnit = APIServices.shared.settings.lengthUnit.title

        let presenter = Appearance.defaultPresenter()
        let pickerVC = PickerViewController(with: units, selectedItem: selectedUnit)
        pickerVC.delegate = self
        pickerVC.title = Row.lengthUnit.title

        let pickerVN = NavigationController(rootViewController: pickerVC)

        customPresentViewController(presenter, viewController: pickerVN, animated: true)
    }

    fileprivate func submitFeedback() {
        if let url = URL(string: MGPWeb.getPrefilledFeedbackFormUrl()) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    fileprivate func openSeasonRulesPage() {
        if let url = URL(string: MGPWebConstant.seasonRules2020.rawValue) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    fileprivate func openHomePage() {
        if let url = URL(string: MGPWebConstant.home.rawValue) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    fileprivate func switchEnvironment() {
        // inverted environment
        let environment = APIServices.shared.settings.isDev ? APIEnvironment.prod : APIEnvironment.dev

        ActionSheetUtil.presentDestructiveActionSheet(withTitle: "Are you sure you want to switch to \(environment.title)?", destructiveTitle: "Yes, switch", completion: { (action) in
            ApplicationControl.shared.logout(switchTo: environment)
        }, cancel: nil)
    }

    fileprivate func logout() {
        ActionSheetUtil.presentDestructiveActionSheet(withTitle: "Are you sure you want to log out?", destructiveTitle: "Yes, log out", completion: { (action) in
            ApplicationControl.shared.logout()
        }, cancel: nil)
    }
}

extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section), let rows = sections[section] else { return }
        let row = rows[indexPath.row]

        if row == .searchRadius {
            setSearchRadius(row)
        } else if row == .lengthUnit {
            setLengthUnit(row)
        } else if row == .submitFeedback {
            submitFeedback()
        } else if row == .readRules {
            openSeasonRulesPage()
        } else if row == .visitSite {
            openHomePage()
        } else if row == .logout {
            logout()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection sectionIdx: Int) -> String? {
        guard let section = Section(rawValue: sectionIdx) else { return nil }
        return section.title
    }
}

extension SettingsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIdx: Int) -> Int {
        guard let section = Section(rawValue: sectionIdx), let rows = sections[section] else { return 0 }
        return rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTableViewCell.identifier) as! FormTableViewCell

        guard let section = Section(rawValue: indexPath.section), let rows = sections[section] else { return cell }
        let row = rows[indexPath.row]

        let settings = APIServices.shared.settings

        cell.textLabel?.text = row.title
        cell.textLabel?.textColor = Color.black
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .disclosureIndicator

        if row == .logout {
            cell.textLabel?.textColor = Color.red
            cell.textLabel?.textAlignment = .center
            cell.accessoryType = .none
        }

        if row == .searchRadius {
            cell.detailTextLabel?.text = "\(settings.searchRadius) \(settings.lengthUnit.symbol)"
        } else if row == .lengthUnit {
            cell.detailTextLabel?.text = settings.lengthUnit.title
        } else if row == .submitFeedback {
            cell.detailTextLabel?.text = "\(Bundle.main.releaseDescriptionPretty)"
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let section = Section(rawValue: section), section == .auth {
            return StringConstants.Copyright
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
}

extension SettingsViewController: FormViewControllerDelegate {

    func formViewController(_ viewController: FormViewController, didSelectItem item: String) {
        guard let row = selectedRow else { return }

        let settings = APIServices.shared.settings

        if row == .searchRadius {
            settings.searchRadius = item
        } else if row == .lengthUnit, let unit = APIUnitSystem(title: item) {

            let previousUnit = settings.lengthUnit
            APIServices.shared.settings.lengthUnit = unit

            // we are forced to update the search radius, with a supported value
            if let idx = previousUnit.supportedValues.firstIndex(of: settings.searchRadius) {
                let value = unit.supportedValues[idx]
                APIServices.shared.settings.searchRadius = value
            }
        }

        tableView.reloadData()
        viewController.dismiss(animated: true, completion: nil)
    }

    func formViewControllerDidDismiss(_ viewController: FormViewController) {
        //
    }
}

fileprivate enum Section: Int, EnumTitle, CaseIterable {
    case search, about, auth

    var title: String {
        switch self {
        case .search:               return "Search"
        case .about:                return "About"
        case .auth:                 return ""
        }
    }
}

fileprivate enum Row: Int, EnumTitle, CaseIterable {
    case searchRadius
    case lengthUnit

    case submitFeedback
    case readRules
    case visitSite

//    case switchEnv
    case logout

    var title: String {
        switch self {
        case .searchRadius:         return "Search Radius"
        case .lengthUnit:           return "Length Unit"

        case .submitFeedback:       return "Feedback"
        case .readRules:            return "2020 Season Rules"
        case .visitSite:            return "Go to multigp.com"

//        case .switchEnv:            return "Switch to"
        case .logout:               return "Logout"
        }
    }
}
