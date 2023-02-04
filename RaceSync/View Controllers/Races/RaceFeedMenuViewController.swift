//
//  RaceFeedMenuViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2023-01-16.
//  Copyright © 2023 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI
import SnapKit

class RaceFeedMenuViewController: UIViewController {

    // MARK: - Public Variables


    // MARK: - Private Variables

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(cellType: FormTableViewCell.self)
        tableView.contentInsetAdjustmentBehavior = .always
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self

        let backgroundView = UIView()
        backgroundView.backgroundColor = Color.white
        tableView.backgroundView = backgroundView

        return tableView
    }()

    fileprivate lazy var rows: [Row] = {
        var rows = [Row]()
        if isPastEventsEnabled { rows += [.showPastEvents]}
        rows += [.searchRadius, .measurement]
        return rows
    }()

    fileprivate let isPastEventsEnabled: Bool = false

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = 60
    }

    // MARK: - Initialization

//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }

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
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        title = "Race Feed Options"
        view.backgroundColor = Color.white

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
        let row = rows[sender.tag]

        if row == .showPastEvents {
            let settings = APIServices.shared.settings
            settings.showPastEvents = !settings.showPastEvents // invert the value
        }
    }

    @objc fileprivate func didPressCloseButton() {
        dismiss(animated: true)
    }
}

extension RaceFeedMenuViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let row = rows[indexPath.row]
        let settings = APIServices.shared.settings

        if row == .searchRadius {
            let items = settings.lengthUnit.supportedValues
            let selectedItem = settings.searchRadius

            let vc = TextPickerViewController(with: items, selectedItem: selectedItem)
            vc.title = "\(row.title) (\(settings.lengthUnit.symbol))"

            navigationController?.pushViewController(vc, animated: true)

            vc.didSelectItem = { item in
                let settings = APIServices.shared.settings
                settings.searchRadius = item

                self.tableView.reloadData()
                self.navigationController?.popViewController(animated: true)
            }

        } else if row == .measurement {
            let items = APIMeasurementSystem.allCases.compactMap { $0.title }
            let selectedItem = settings.measurementSystem.title

            let vc = TextPickerViewController(with: items, selectedItem: selectedItem)
            vc.title = row.title
            navigationController?.pushViewController(vc, animated: true)

            vc.didSelectItem = { item in
                guard let system = APIMeasurementSystem(title: item) else { return }

                let previousUnit = settings.lengthUnit
                settings.measurementSystem = system
                let newUnit = settings.lengthUnit

                // To make values compatible, we user similar lenghts instead of converting and having values with decimals
                if let idx = previousUnit.supportedValues.firstIndex(of: settings.searchRadius) {
                    let value = newUnit.supportedValues[idx]
                    settings.update(searchRadius: value)
                }

                self.tableView.reloadData()
                self.navigationController?.popViewController(animated: true)
            }
        }

    }
}

extension RaceFeedMenuViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIdx: Int) -> Int {
        return rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as FormTableViewCell
        let row = rows[indexPath.row]

        cell.textLabel?.text = row.title
        cell.detailTextLabel?.text = nil
        cell.textLabel?.textColor = Color.black
        cell.imageView?.image = UIImage.init(named: row.imageName)
        cell.accessoryType = .disclosureIndicator

        let settings = APIServices.shared.settings

        if row == .showPastEvents {
            cell.accessoryType = .none
            let accessory = UISwitch()

            accessory.tag = rows.firstIndex(of: row) ?? 0
            accessory.addTarget(self, action: #selector(didChangeSwitchValue(_:)), for: .valueChanged)
            accessory.isOn = settings.showPastEvents
            cell.accessoryView = accessory
        } else if row == .searchRadius {
            cell.detailTextLabel?.text = "\(settings.searchRadius) \(settings.lengthUnit.symbol)"
        } else if row == .measurement {
            cell.detailTextLabel?.text = settings.measurementSystem.title
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
}

private enum Section: Int, EnumTitle {
    case general

    var title: String {
        switch self {
        case .general:          return "General"
        }
    }
}

private typealias Row = APISettingsType

private extension APISettingsType {

    // For including icons to each row. Look for icons at https://thenounproject.com/
    var imageName: String {
        switch self {
        case .searchRadius:     return "icn_settings_radius"
        case .measurement:      return "icn_settings_ruler"
        default:                return ""
        }
    }
}
