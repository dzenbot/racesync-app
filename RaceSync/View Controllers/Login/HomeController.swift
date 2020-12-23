//
//  HomeController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-03-05.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit

class HomeController {

    static let isV2enabled: Bool = false

    static func homeViewController() -> UIViewController {
        if isV2enabled {

            let racesVC = RaceListViewController([.joined, .nearby], selectedType: .nearby)
            racesVC.tabBarItem = UITabBarItem(title: "Races", image: UIImage(named: "icn_tab_race"), tag: 0)
            let racesNC = NavigationController(rootViewController: racesVC)

            let qualisVC = RaceListViewController([.openQuali, .megaQuali], selectedType: .openQuali)
            qualisVC.tabBarItem = UITabBarItem(title: "Qualifiers", image: UIImage(named: "icn_tab_race"), tag: 1)
            let qualisNC = NavigationController(rootViewController: qualisVC)

            let leaderboardVC = LeaderboardViewController()
            leaderboardVC.tabBarItem = UITabBarItem(title: "Leaderboard", image: UIImage(named: "icn_tab_race"), tag: 2)
            let leaderboardNC = NavigationController(rootViewController: leaderboardVC)

            let tabBarController = UITabBarController()
            tabBarController.viewControllers = [racesNC, qualisNC, leaderboardNC]

            return tabBarController
        } else {
            let raceListVC = RaceListViewController([.joined, .nearby], selectedType: .nearby)
            let raceListNC = NavigationController(rootViewController: raceListVC)
            return raceListNC
        }
    }
}
