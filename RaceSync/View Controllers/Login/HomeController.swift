//
//  HomeController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-03-05.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit

class HomeController {

    static func homeViewController() -> UIViewController {
        let raceListVC = RaceListViewController([.joined, .nearby, .schedule], selectedType: .nearby)
        let raceListNC = NavigationController(rootViewController: raceListVC)
        return raceListNC
    }
}
