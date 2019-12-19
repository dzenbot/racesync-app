//
//  ProfileViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-25.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit

enum ProfileSegment: Int {
    case left, right
}

class ProfileViewController: UIViewController {

    // MARK: - Public Variables

    public let profileViewModel: ProfileViewModel

    public let headerView = ProfileHeaderView()

    public lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.register(SegmentedTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: SegmentedTableViewHeaderView.identifier)
        tableView.contentInsetAdjustmentBehavior = .always
        tableView.tableFooterView = UIView()

        for direction in [UISwipeGestureRecognizer.Direction.left, UISwipeGestureRecognizer.Direction.right] {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeHorizontally(_:)))
            gesture.direction = direction
            tableView.addGestureRecognizer(gesture)
        }

        return tableView
    }()

    public var segmentedControl: UISegmentedControl? {
        didSet {
            segmentedControl?.setTitle(profileViewModel.leftSegmentLabel, forSegmentAt: ProfileSegment.left.rawValue)
            segmentedControl?.setTitle(profileViewModel.rightSegmentLabel, forSegmentAt: ProfileSegment.right.rawValue)
            segmentedControl?.addTarget(self, action: #selector(didChangeSegment), for: .valueChanged)
        }
    }

    public var selectedSegment: ProfileSegment {
        get {
            if segmentedControl?.selectedSegmentIndex == ProfileSegment.right.rawValue {
                return .right
            }
            return .left
        }
    }

    // MARK: - Private Variables

    fileprivate var topOffset: CGFloat {
        get {
            let status_height = UIApplication.shared.statusBarFrame.height
            let navi_height = navigationController?.navigationBar.frame.size.height ?? 44
            return status_height + navi_height
        }
    }

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
    }

    // MARK: - Initialization

    init(with profileViewModel: ProfileViewModel) {
        self.profileViewModel = profileViewModel
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
        tableView.layoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    open func setupLayout() {
        view.backgroundColor = Color.white
        navigationItem.title = profileViewModel.title

        headerView.topLayoutInset = topOffset
        headerView.viewModel = profileViewModel
        tableView.tableHeaderView = headerView
        view.addSubview(tableView)

        tableView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.height.greaterThanOrEqualTo(0)
            $0.width.equalTo(UIScreen.main.bounds.width)
        }

        headerView.snp.makeConstraints {
            $0.size.equalTo(headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize))
        }
    }

    // MARK: - Actions

    @objc open func didChangeSegment() {
        if tableView.contentOffset.y >= headerView.frame.height + topOffset {
            tableView.contentOffset = CGPoint(x: 0, y: headerView.frame.height-topOffset)
        }
    }

    @objc open func didSwipeHorizontally(_ sender: Any) {
        guard let swipeGesture = sender as? UISwipeGestureRecognizer, let segmentedControl = segmentedControl else { return }

        if swipeGesture.direction == .left && selectedSegment != .right {
            segmentedControl.selectedSegmentIndex = ProfileSegment.right.rawValue
        } else if swipeGesture.direction == .right && selectedSegment != .left {
            segmentedControl.selectedSegmentIndex = ProfileSegment.left.rawValue
        }

        segmentedControl.sendActions(for: .valueChanged)
    }

    @objc open func didSelectRow(at indexPath: IndexPath) {
        //
    }
}

extension ProfileViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelectRow(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: SegmentedTableViewHeaderView.identifier) as? SegmentedTableViewHeaderView {
            segmentedControl = header.segmentedControl
            return header
        }
        return nil
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SegmentedTableViewHeaderView.headerHeight
    }
}

// MARK: - ScrollView Delegate

extension ProfileViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        stretchHeaderView(with: scrollView.contentOffset)
    }
}

// MARK: - HeaderStretchable

extension ProfileViewController: HeaderStretchable {

    var targetHeaderView: UIView {
        return headerView.backgroundImageView
    }

    var targetHeaderViewSize: CGSize {
        return headerView.backgroundImageViewSize
    }

    var topLayoutInset: CGFloat {
        return topOffset
    }
}
