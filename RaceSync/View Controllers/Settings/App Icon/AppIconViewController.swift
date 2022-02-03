//
//  AppIconViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2021-08-23.
//  Copyright © 2021 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import RaceSyncAPI

class AppIconViewController: UIViewController {

    // MARK: - Private Variables

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(cellType: FormTableViewCell.self)

        let backgroundView = UIView()
        backgroundView.backgroundColor = Color.gray20
        tableView.backgroundView = backgroundView

        return tableView
    }()

    fileprivate lazy var sections: [Section: [AppIcon]] = {
        var list = [Section.mgp: [AppIcon.default, .blue, .white, .io2022]]

        if isChapterIconEnabled {
            list += [Section.chapters: [AppIcon.kru]]
        }
        return list
    }()

    fileprivate let appIconManager = AppIconManager()

    fileprivate var isChapterIconEnabled: Bool {
        if let myUser = APIServices.shared.myUser, myUser.id == "20676" {
            return true
        } else { return false }
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
    }

    // MARK: - Layout

    fileprivate func setupLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }
    }

    fileprivate func getAppIcon(at indexPath: IndexPath) -> AppIcon {
        guard let section = Section(rawValue: indexPath.section), let rows = sections[section] else { return .default }
        return rows[indexPath.row]
    }
}

extension AppIconViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let currentAppIcon = AppIconManager.current()
        let appIcon = getAppIcon(at: indexPath)

        guard appIcon != currentAppIcon else { return }

        AppIconManager.setIcon(appIcon) { (didSet) in
            tableView.reloadData()
        }
    }
}

extension AppIconViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection sectionIdx: Int) -> Int {
        guard let section = Section(rawValue: sectionIdx), let rows = sections[section] else { return 0 }
        return rows.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return iconTableViewCell(for: indexPath)
    }

    func iconTableViewCell(for indexPath: IndexPath) -> FormTableViewCell {
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as FormTableViewCell
        let appIcon = getAppIcon(at: indexPath)

        cell.textLabel?.text = appIcon.title
        cell.imageView?.image = appIcon.preview?.rounded(with: 60 / 4)
        cell.imageView?.layer.shadowColor = Color.black.cgColor
        cell.imageView?.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        cell.imageView?.layer.shadowOpacity = 0.2
        cell.imageView?.layer.shadowRadius = 3
        cell.accessoryType = .none

        if AppIconManager.current() == appIcon {
            let imageView = UIImageView(image: UIImage(named: "icn_cell_checkmark"))
            imageView.tintColor = Color.blue
            cell.accessoryView = imageView
        } else {
            cell.accessoryView = nil
        }

        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection sectionIdx: Int) -> String? {
        guard let section = Section(rawValue: sectionIdx) else { return nil }
        return section.title
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let section = Section(rawValue: section), section == .chapters {
            return "Want to include your chapter's icon? Contact us at ios@multigp.com"
        } else {
            return nil
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UniversalConstants.cellHeight
    }
}

fileprivate enum Section: Int, EnumTitle, CaseIterable {
    case mgp, chapters

    var title: String {
        switch self {
        case .mgp:          return "MultiGP"
        case .chapters:     return "Chapters"
        }
    }
}
