//
//  ProfileViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-25.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import ShimmerSwift

enum ProfileSegment: Int {
    case left, right
}

class ProfileViewController: UIViewController, Shimmable {

    // MARK: - Public Variables

    let profileViewModel: ProfileViewModel

    let headerView = ProfileHeaderView()
    let shimmeringView: ShimmeringView = defaultShimmeringView()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.register(SegmentedTableViewHeaderView.self, forHeaderFooterViewReuseIdentifier: SegmentedTableViewHeaderView.identifier)
        tableView.contentInsetAdjustmentBehavior = .always
        tableView.alwaysBounceVertical = true
        tableView.tableFooterView = UIView()

        for direction in [UISwipeGestureRecognizer.Direction.left, UISwipeGestureRecognizer.Direction.right] {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeHorizontally(_:)))
            gesture.direction = direction
            tableView.addGestureRecognizer(gesture)
        }

        return tableView
    }()

    var segmentedControl: UISegmentedControl? {
        didSet {
            segmentedControl?.setTitle(profileViewModel.leftSegmentLabel, forSegmentAt: ProfileSegment.left.rawValue)
            segmentedControl?.setTitle(profileViewModel.rightSegmentLabel, forSegmentAt: ProfileSegment.right.rawValue)
            segmentedControl?.addTarget(self, action: #selector(didChangeSegment), for: .valueChanged)
        }
    }

    var selectedSegment: ProfileSegment {
        get {
            if segmentedControl?.selectedSegmentIndex == ProfileSegment.right.rawValue {
                return .right
            }
            return .left
        }
    }

    // MARK: - Private Variables

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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    open func setupLayout() {
        title = profileViewModel.title
        view.backgroundColor = Color.white

        headerView.topLayoutInset = topOffset
        headerView.viewModel = profileViewModel
        headerView.locationButton.addTarget(self, action: #selector(didPressLocationButton), for: .touchUpInside)
        tableView.tableHeaderView = headerView

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalToSuperview()
        }

        let headerViewSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        headerView.snp.makeConstraints {
            $0.size.equalTo(headerViewSize)
        }

        view.addSubview(shimmeringView)
        shimmeringView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(headerViewSize.height + Constants.padding*2 + SegmentedTableViewHeaderView.headerHeight)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }

    // MARK: - Actions

    @objc open func didChangeSegment() {
        if tableView.contentOffset.y >= headerView.frame.height + topOffset {
            tableView.contentOffset = CGPoint(x: 0, y: headerView.frame.height-topOffset)
        }
    }

    @objc open func didPressLocationButton() {
        // To be implemented by subclass
    }

    @objc open func didSwipeHorizontally(_ sender: Any) {
        guard let swipeGesture = sender as? UISwipeGestureRecognizer, let segmentedControl = segmentedControl else { return }

        if swipeGesture.direction == .left && selectedSegment != .right {
            segmentedControl.setSelectedSegment(ProfileSegment.right.rawValue)
        } else if swipeGesture.direction == .right && selectedSegment != .left {
            segmentedControl.setSelectedSegment(ProfileSegment.left.rawValue)
        }
    }

    @objc open func didSelectRow(at indexPath: IndexPath) {
        // To be implemented by subclass
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

    var targetHeaderView: StretchableView {
        return headerView.backgroundView
    }

    var targetHeaderViewSize: CGSize {
        return headerView.backgroundViewSize
    }

    var topLayoutInset: CGFloat {
        return topOffset
    }

    var anchoredViews: [UIView]? {
        return nil
    }
}
