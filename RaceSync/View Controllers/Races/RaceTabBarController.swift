//
//  RaceTabBarController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import SnapKit
import RaceSyncAPI

fileprivate enum RaceTabs: Int {
    case event, race, results
}

class RaceTabBarController: UITabBarController {

    // MARK: - Feature Flags

    fileprivate var initialSelectedIndex: Int = RaceTabs.event.rawValue

    // MARK: - Private Variables

    fileprivate let eventDetailVC: EventDetailViewController
    fileprivate let raceViewModel: RaceViewModel
    fileprivate let raceApi = RaceApi()
    fileprivate var race: Race?

    fileprivate enum Constants {
        static let padding: CGFloat = UniversalConstants.padding
    }

    // MARK: - Initialization

    init(with raceViewModel: RaceViewModel) {
        self.raceViewModel = raceViewModel
        self.eventDetailVC = EventDetailViewController(with: raceViewModel)

        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = self

        raceApi.viewSimple(race: raceViewModel.race.id) { (race, error) in
            self.race = race
            self.configureViewControllers()
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    fileprivate func configureViewControllers() {
        guard let race = race else { return }

        eventDetailVC.race = race // sketch for now!
        let raceDetailVC = RaceDetailViewController(with: race)
        let raceResultsVC = RaceResultsViewController(with: race)

        viewControllers = [eventDetailVC, raceDetailVC, raceResultsVC]

        // Dirty little trick to select the first tab bar item
        self.selectedIndex = initialSelectedIndex+1
        self.selectedIndex = initialSelectedIndex

        // pre-load each view
        preloadTabs()

        tabBar.tintColor = Color.black
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icn_share"), style: .done, target: self, action: #selector(shareRace))
    }

    // MARK: - Actions

    override var selectedIndex: Int {
        didSet {
            didSelectedIndex(selectedIndex)
        }
    }

    fileprivate func didSelectedIndex(_ index: Int) {
        title = viewControllers?[index].title
    }

    @objc func shareRace(_ sender: UIBarButtonItem) {
        // TODO: Should use self.race but sometimes id is nil. Related to https://github.com/dzenbot/RaceSync/issues/36
        guard let raceUrl = URL(string: raceViewModel.race.url) else { return }

        let items = [raceUrl]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityVC, animated: true)
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
