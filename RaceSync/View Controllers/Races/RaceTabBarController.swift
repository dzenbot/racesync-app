//
//  RaceTabBarController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import EmptyDataSet_Swift
import RaceSyncAPI

enum RaceTabs: Int {
    case event, race, results
}

class RaceTabBarController: UITabBarController {

    // MARK: - Public Variables

    var isLoading: Bool = false {
        didSet {
            if isLoading { activityIndicatorView.startAnimating() }
            else { activityIndicatorView.stopAnimating() }
        }
    }

    override var selectedIndex: Int {
        didSet {
            didSelectedIndex(selectedIndex)
        }
    }

    // MARK: - Private Variables

    let isResultsTabEnabled: Bool = false

    fileprivate lazy var activityIndicatorView: UIActivityIndicatorView = {
        return UIActivityIndicatorView(style: .whiteLarge)
    }()

    fileprivate var initialSelectedIndex: Int = RaceTabs.event.rawValue

    fileprivate let raceApi = RaceApi()
    fileprivate var raceId: ObjectId
    fileprivate var race: Race?

    fileprivate var emptyStateError: EmptyStateViewModel?

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
    }

    // MARK: - Initialization

    init(with raceId: ObjectId) {
        self.raceId = raceId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        loadRaceView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    fileprivate func setupLayout() {

        title = ""
        view.backgroundColor = Color.white

        tabBar.isHidden = true
        delegate = self

        view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }
    }

    fileprivate func configureViewControllers(with race: Race) {

        var vcs = [UIViewController]()
        vcs += [RaceDetailViewController(with: race)]
        vcs += [RaceRosterViewController(with: race)]

        if isResultsTabEnabled {
            vcs += [RaceResultsViewController(with: race)]
        }

        viewControllers = vcs

        // Dirty little trick to select the first tab bar item
        self.selectedIndex = initialSelectedIndex+1
        self.selectedIndex = initialSelectedIndex

        // Trick to pre-load each view controller
        preloadTabs()
        tabBar.isHidden = false
    }

    // MARK: - Actions

    func selectTab(_ tab: RaceTabs) {
        selectedIndex = tab.rawValue
    }

    fileprivate func didSelectedIndex(_ index: Int) {
        guard let vc = viewControllers?[index] else { return }

        title = vc.title
        navigationItem.rightBarButtonItem = vc.navigationItem.rightBarButtonItem
    }

    // MARK: - Error

    fileprivate func handleError(_ error: Error) {

        emptyStateError = EmptyStateViewModel(.errorRaces)

        // temporary scroll view used to display the error message
        let scrollView = UIScrollView()
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.emptyDataSetDelegate = self
        scrollView.emptyDataSetSource = self

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.leading.trailing.equalToSuperview()
        }

        scrollView.reloadEmptyDataSet()
    }
}

extension RaceTabBarController {

    func loadRaceView() {
        guard !isLoading else { return }

        isLoading = true

        raceApi.viewSimple(race: raceId) { [weak self] (race, error) in
            self?.isLoading = false

            if let race = race {
                self?.race = race
                self?.configureViewControllers(with: race)
            } else if let error = error {
                self?.handleError(error)
            }
        }
    }

    func reloadRaceView() {
        guard !isLoading else { return }

        raceApi.viewSimple(race: raceId) { [weak self] (race, error) in
            guard let race = race, let vcs = self?.viewControllers else { return }

            self?.race = race

            for vc in vcs {
                guard var vcc = vc as? RaceTabbable else { continue }
                vcc.race = race
                vcc.reloadContent()
            }
        }
    }
}

extension RaceTabBarController: EmptyDataSetSource {

    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return emptyStateError?.title
    }

    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        return emptyStateError?.description
    }

    func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        return emptyStateError?.buttonTitle(state)
    }
}

extension RaceTabBarController: EmptyDataSetDelegate {

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView) -> Bool {
        return false
    }

    func emptyDataSet(_ scrollView: UIScrollView, didTapButton button: UIButton) {
        guard let url = MGPWeb.getPrefilledFeedbackFormUrl() else { return }
        WebViewController.openUrl(url)
    }
}

extension RaceTabBarController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let index = viewControllers?.lastIndex(of: viewController) {
            didSelectedIndex(index)
        }
    }
}
