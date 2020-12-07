//
//  TrackDetailViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-04.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import RaceSyncAPI

class TrackDetailViewController: UIViewController {

    // MARK: - Private Variables

    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.identifier)

        let backgroundView = UIView()
        backgroundView.backgroundColor = Color.gray20
        tableView.backgroundView = backgroundView

        return tableView
    }()

    fileprivate var tableViewRowCount: Int {
        get {
            return Row.allCases.count
        }
    }

    fileprivate var didTapCell: Bool = false

    fileprivate let viewModel: TrackViewModel
    fileprivate var userApi = UserApi()

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
        static let cellHeight: CGFloat = 50
    }

    // MARK: - Initialization

    init(with viewModel: TrackViewModel) {
        self.viewModel = viewModel
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
    }

    // MARK: - Layout

    func setupLayout() {
        title = viewModel.titleLabel
        view.backgroundColor = Color.white

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
//            $0.height.equalTo(Constants.cellHeight*CGFloat(tableViewRowCount))
        }
    }

    // MARK: - Actions

    func showUserProfile(_ cell: FormTableViewCell) {
        guard !didTapCell else { return }
        setLoading(cell, loading: true)

        userApi.searchUser(with: viewModel.track.designer) { [weak self] (user, error) in
            self?.setLoading(cell, loading: false)

            if let user = user {
                let userVC = UserViewController(with: user)
                self?.navigationController?.pushViewController(userVC, animated: true)
            } else if let _ = error {
                // handle error
            }
        }
    }

    func setLoading(_ cell: FormTableViewCell, loading: Bool) {
        cell.isLoading = loading
        didTapCell = loading
    }

}

// MARK: - UITableView Delegate

extension TrackDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FormTableViewCell else { return }
        guard let row = Row(rawValue: indexPath.row) else { return }

        if row == .designer {
            showUserProfile(cell)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TrackDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewRowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTableViewCell.identifier) as! FormTableViewCell
        guard let row = Row(rawValue: indexPath.row) else { return cell }

        let track = viewModel.track
        cell.textLabel?.text = row.title

        if row == .elements {
            cell.detailTextLabel?.text = ""
        } else if row == .`class` {
            cell.detailTextLabel?.text = track.class.title
        } else if row == .designer {
            cell.detailTextLabel?.text = track.designer
        }

        cell.isLoading = false

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.cellHeight
    }
}


fileprivate enum Row: Int, EnumTitle, CaseIterable {
    case elements, `class`, designer

    var title: String {
        switch self {
        case .elements:     return "Course Elements"
        case .`class`:      return "Class"
        case .designer:     return "Designer"
        }
    }
}
