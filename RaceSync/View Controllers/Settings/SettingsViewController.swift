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
        tableView.tableHeaderView = headerView
        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.identifier)
        return tableView
    }()

    lazy var headerView: UIView = {
        let view = UIView()

        let imageView = UIImageView(image: UIImage(named: "icn_settings_header"))
        view.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-100)
        }

        return view
    }()

    lazy var pickerView: UIPickerView = {
        let view = UIPickerView()
        view.backgroundColor = Color.white
        view.dataSource = self
        view.delegate = self

        let radius = APIServices.shared.settings.searchRadius
        if let row = distances.firstIndex(of: radius) {
            view.selectRow(row, inComponent: 0, animated: false)
        }

        return view
    }()

    fileprivate let distances: [CGFloat] = [CGFloat(200), CGFloat(500), CGFloat(1000), CGFloat(2000), CGFloat(5000)]

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
            let dummy = UITextField(frame: .zero)
            view.addSubview(dummy)

            dummy.inputView = pickerView
            dummy.becomeFirstResponder()
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
        cell.textLabel?.textColor = Color.black
        cell.detailTextLabel?.text = nil
        cell.accessoryType = .disclosureIndicator

        if section == .logout {
            cell.textLabel?.textColor = Color.red
            cell.accessoryType = .none
        }

        if section == .searchRadius {
            cell.detailTextLabel?.text = "\(APIServices.shared.settings.searchRadius) mi"
        } else if section == .submitFeedback {
            cell.detailTextLabel?.text = "\(Bundle.main.releaseDescriptionPretty)"
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

extension SettingsViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return distances.count
    }
}

extension SettingsViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let distance = distances[row]
        return "\(distance) mi"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let distance = distances[row]

        APIServices.shared.settings.searchRadius = CGFloat(distance)
        tableView.reloadData()
    }
}

