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
        let vc = RaceMainListViewController(availableFilters(), selectedFilter: .nearby)
        return NavigationController(rootViewController: vc)
    }

    static func availableFilters() -> [RaceFilter] {
        return [.joined, .nearby, .series]
    }
}
