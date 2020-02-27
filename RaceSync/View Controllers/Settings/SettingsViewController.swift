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

fileprivate enum SettingsSection: Int, EnumTitle, CaseIterable {
    case searchRadius
    case submitFeedback
    case switchEnvironment
    case logout

    var title: String {
        switch self {
        case .searchRadius:         return "Search Radius"
        case .submitFeedback:       return "Submit Feedback"
        case .switchEnvironment:    return "Switch to"
        case .logout:               return "Logout"
        }
    }
}

class SettingsViewController: UIViewController {

    // MARK: - Private Variables

    var adjustRadiusEnabled: Bool = false

    // MARK: - Private Variables

   fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = headerView
        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.identifier)

        let backgroundView = UIView()
        backgroundView.backgroundColor = Color.gray50
        tableView.backgroundView = backgroundView

        return tableView
    }()

    fileprivate lazy var headerView: UIView = {
        let view = UIView()

        let imageView = UIImageView(image: UIImage(named: "icn_settings_header"))
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-100)
        }

        return view
    }()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = 50
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

        if adjustRadiusEnabled {
            DispatchQueue.main.async { [weak self] in
                self?.changeSearchRadius()
            }
        }
    }

    // MARK: - Layout

    func setupLayout() {

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - Actions

    @objc func didPressCloseButton() {
        dismiss(animated: true, completion: nil)
    }

    func changeSearchRadius() {
        adjustRadiusEnabled = false

        let selectedDistance = APIServices.shared.settings.searchRadius

        let presenter = Appearance.defaultPresenter()
        let pickerVC = PickerViewController(with: SearchRadiuses, selectedItem: selectedDistance)
        pickerVC.delegate = self
        pickerVC.title = "Update \(SettingsSection.searchRadius.title)"
        pickerVC.unit = "mi"

        let pickerVN = NavigationController(rootViewController: pickerVC)
        
        customPresentViewController(presenter, viewController: pickerVN, animated: true)
    }

    func submitFeedback() {
        if let url = URL(string: MGPWeb.getPrefilledFeedbackFormUrl()) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    func switchEnvironment() {
        // inverted environment
        let environment = APIServices.shared.settings.isDev ? APIEnvironment.prod : APIEnvironment.dev

        ActionSheetUtil.presentDestructiveActionSheet(withTitle: "Are you sure you want to switch to \(environment.title)?", destructiveTitle: "Yes, switch", completion: { (action) in
            ApplicationControl.shared.logout(switchTo: environment)
        }, cancel: nil)
    }

    func logout() {
        ActionSheetUtil.presentDestructiveActionSheet(withTitle: "Are you sure you want to log out?", destructiveTitle: "Yes, log out", completion: { (action) in
            ApplicationControl.shared.logout()
        }, cancel: nil)
    }
}

extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = SettingsSection(rawValue: indexPath.section)

        if section == .searchRadius {
            changeSearchRadius()
        } else if section == .submitFeedback {
            submitFeedback()
        } else if section == .switchEnvironment {
            switchEnvironment()
        } else if section == .logout {
            logout()
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = SettingsSection(rawValue: section) else { return 0 }

        if section == .switchEnvironment, let stage = CrashCatcher.config.releaseStage {
            if stage == APIReleaseStage.alpha.rawValue || stage == APIReleaseStage.development.rawValue { return 1 }
            else { return 0 }
        }

        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTableViewCell.identifier) as! FormTableViewCell

        guard let section = SettingsSection(rawValue: indexPath.section) else { return cell }

        cell.textLabel?.text = section.title
        cell.textLabel?.textColor = Color.black
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .disclosureIndicator

        if section == .logout || section == .switchEnvironment {
            cell.textLabel?.textColor = Color.red
            cell.accessoryType = .none
        }

        if section == .searchRadius {
            cell.detailTextLabel?.text = "\(APIServices.shared.settings.searchRadius) mi"
        } else if section == .submitFeedback {
            cell.detailTextLabel?.text = "\(Bundle.main.releaseDescriptionPretty)"
        } else if section == .switchEnvironment {
            let environment = APIServices.shared.settings.isDev ? "Prod" : "Dev"
            cell.textLabel?.text = "\(section.title) \(environment)"
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {

        if section == SettingsSection.logout.rawValue {
            return StringConstants.Copyright
        } else {
            return nil
        }
    }
}

extension SettingsViewController: FormViewControllerDelegate {

    func formViewController(_ viewController: FormViewController, didSelectItem item: String) {
        APIServices.shared.settings.searchRadius = item
        tableView.reloadData()

        viewController.dismiss(animated: true, completion: nil)
    }

    func formViewControllerDidDismiss(_ viewController: FormViewController) {
        //
    }
}
