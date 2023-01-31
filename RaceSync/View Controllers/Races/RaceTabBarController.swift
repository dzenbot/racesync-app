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

    var isDismissable: Bool = false {
        didSet {
            if isDismissable {
                navigationItem.leftBarButtonItem = UIBarButtonItem(image: ButtonImg.close, style: .done, target: self, action: #selector(didPressCloseButton))
                navigationItem.backBarButtonItem = nil
            } else {
                navigationItem.leftBarButtonItem = nil
            }
        }
    }

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

    fileprivate lazy var titleButton: PasteboardButton = {
        let button = PasteboardButton(type: .system)
        button.addTarget(self, action: #selector(didPressTitleButton), for: .touchUpInside)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.titleLabel?.textAlignment = .center
        button.setTitleColor(Color.black, for: .normal)
        button.setTitle(self.title, for: .normal)
        return button
    }()

    let isResultsTabEnabled: Bool = false

    fileprivate lazy var activityIndicatorView: UIActivityIndicatorView = {
        return UIActivityIndicatorView(style: .medium)
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

    init(with race: Race) {
        self.race = race
        self.raceId = race.id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()

        if let race = race {
            configureViewControllers(with: race)
        } else {
            loadRaceView()
        }
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

        for vc in vcs { vc.willMove(toParent: self) }
        viewControllers = vcs
        for vc in vcs { vc.didMove(toParent: self) }

        // Dirty little trick to select the first tab bar item
        self.selectedIndex = initialSelectedIndex+1
        self.selectedIndex = initialSelectedIndex

        // Trick to pre-load each view controller
        preloadTabs()
        tabBar.isHidden = false

        // Using a custom button title in this case, to display the id of a Race on tap
        navigationItem.titleView = titleButton
    }

    // MARK: - Actions

    func selectTab(_ tab: RaceTabs) {
        selectedIndex = tab.rawValue
    }

    fileprivate func didSelectedIndex(_ index: Int) {
        guard let vc = viewControllers?[index] else { return }

        title = vc.title
        titleButton.setTitle(title, for: .normal)

        navigationItem.rightBarButtonItem = vc.navigationItem.rightBarButtonItem
    }

    @objc fileprivate func didPressCloseButton() {
        dismiss(animated: true)
    }

    @objc fileprivate func didPressTitleButton() {
        guard let race = race else { return }

        let btnTitle = titleButton.title(for: .normal)
        let id = race.id

        if btnTitle == title {
            titleButton.setTitle(id, for: .normal)
        } else if btnTitle == id {
            titleButton.setTitle(title, for: .normal)
        }
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

            for viewcontroller in vcs {
                guard var vc = viewcontroller as? RaceTabbable else { continue }
                vc.race = race
                vc.reloadContent()
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
        guard let url = AppWebConstants.getPrefilledFeedbackFormUrl() else { return }
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
