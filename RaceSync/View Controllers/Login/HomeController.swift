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
        return NavigationController(rootViewController: vc)
    }

    static func availableFilters() -> [RaceFilter] {

        var filters: [RaceFilter] = [.joined, .nearby]

        // Only show GQ races while the season is on going
        if Season.isGQWindow(10) {
            filters += [.series]
        } else if let user = APIServices.shared.myUser, user.isDevTeam {
            filters += [.chapters]
        }

        return filters
    }
}
