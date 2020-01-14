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

    fileprivate lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .gray)
        view.hidesWhenStopped = true
        view.color = Color.blue
        return view
    }()

    fileprivate lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.textColor = Color.gray300
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    fileprivate let raceApi = RaceApi()
    fileprivate var raceId: ObjectId
    fileprivate var race: Race? {
        // TODO: Patch for race/simpleView which doesn't provide the id attribute for a Race.
        // https://github.com/mainedrones/RaceSync/pull/37
        didSet { race?.id = raceId }
    }

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

        view.backgroundColor = Color.white
        delegate = self

        view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }

        view.addSubview(errorLabel)
        errorLabel.snp.makeConstraints {
            $0.centerX.centerY.equalToSuperview()
        }

        activityIndicatorView.startAnimating()

        raceApi.viewSimple(race: raceId) { [weak self] (race, error) in
            
            self?.activityIndicatorView.stopAnimating()

            if let _ = error {
                self?.errorLabel.isHidden = false
                self?.errorLabel.text = "Could not load the race details.\nPlease try again later."
            } else {
                self?.race = race
                self?.configureViewControllers()
            }
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

        let eventDetailVC = EventDetailViewController(with: race)
        let raceDetailVC = RaceDetailViewController(with: race)
        let raceResultsVC = RaceResultsViewController(with: race)

        viewControllers = [eventDetailVC, raceDetailVC, raceResultsVC]

        // Dirty little trick to select the first tab bar item
        self.selectedIndex = initialSelectedIndex+1
        self.selectedIndex = initialSelectedIndex

        // Trick to pre-load each view controller
        preloadTabs()

        tabBar.tintColor = Color.black
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icn_share"), style: .done, target: self, action: #selector(didPressShareButton))
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

    @objc func didPressShareButton() {
        guard let race = race, let raceUrl = URL(string: race.url) else { return }

        var items: [Any] = [raceUrl]
        var activities: [UIActivity] = [SafariActivity()]

        // Calendar integration
        if let startDate = race.startDate, let address = race.address {
            let calendarEvent = CalendarEvent(title: race.name, location: address, description: race.description, startDate: startDate, url: raceUrl)

            items += [calendarEvent]
            activities += [CalendarActivity()]
        }

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: activities)
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
