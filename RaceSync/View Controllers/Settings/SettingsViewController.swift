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

fileprivate enum SettingsSection: Int, CaseIterable {
    case searchRadius
    case submitFeedback
    case logout

    var title: String {
        switch self {
        case .searchRadius:     return "Change Search Radius"
        case .submitFeedback:   return "Submit Feedback"
        case .logout:           return "Logout"
        }
    }
}

class SettingsViewController: UIViewController {

    // MARK: - Private Variables

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = Color.gray50
        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.identifier)
        return tableView
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
}

extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = SettingsSection(rawValue: indexPath.section)

        if section == .searchRadius {

        } else if section == .submitFeedback {
            if let url = URL(string: MGPWeb.getPrefilledFeedbackFormUrl()) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else if section == .logout {
            ActionSheetUtil.presentDestructiveActionSheet(withTitle: "Are you sure you want to log out?", destructiveTitle: "Yes, log out", completion: { (action) in
                ApplicationControl.shared.logout()
            }, cancel: nil)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return SettingsSection.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTableViewCell.identifier) as! FormTableViewCell

        let section = SettingsSection(rawValue: indexPath.section)
        cell.textLabel?.text = section?.title
        cell.accessoryType = .disclosureIndicator

        if section == .logout {
            cell.textLabel?.textColor = Color.red
        } else {
            cell.textLabel?.textColor = Color.black
        }

        if section == .searchRadius {
            cell.detailTextLabel?.text = "\(APIServices.shared.settings.radius) mi"
        } else {
            cell.detailTextLabel?.text = nil
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {

        if section == SettingsSection.allCases.count-1 {
            return "RaceSync v1.0 (#002)\nCopyright © 2015 - 2020 MultiGP, Inc."
        } else {
            return nil
        }
    }
}



