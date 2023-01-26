//
//  HomeController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-03-05.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI

class HomeController {

    static func homeViewController() -> UIViewController {
        let vc = RaceFeedViewController(availableFilters(), selectedFilter: .nearby)
        let nc = NavigationController(rootViewController: vc)
        return nc
    }

    static func availableFilters() -> [RaceFilter] {

        var filters: [RaceFilter] = [.joined, .nearby]

        // Only show GQ races while the season is on going
        if Season.isGQWindowValid(10) {
            filters += [.series]
        } else if APIServices.shared.settings.isDev {
            filters += [.chapters]
        }

        return filters
    }
}
