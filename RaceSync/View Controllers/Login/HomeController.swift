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

        let raceListVC = RaceListViewController(availableLists(), selectedType: .nearby)
        let raceListNC = NavigationController(rootViewController: raceListVC)
        return raceListNC
    }

    static func availableLists() -> [RaceListType] {
        if SeasonScheduler.isActive() {
            return [.joined, .nearby, .series]
        } else {
            return [.joined, .nearby]
        }
    }
}
