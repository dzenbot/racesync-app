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

        var listTypes = [RaceListType]()
        let selectedType: RaceListType = .nearby

        if SeasonScheduler.isActive() {
            listTypes = [.joined, .nearby, .series]
        } else {
            listTypes = [.joined, .nearby]
        }

        let raceListVC = RaceListViewController(listTypes, selectedType: selectedType)
        let raceListNC = NavigationController(rootViewController: raceListVC)
        return raceListNC
    }
}
