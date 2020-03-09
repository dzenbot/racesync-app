//
//  NavigationController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-20.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    // Override used for removing the back buttom's label
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem()
        visibleViewController?.navigationItem.backBarButtonItem = UIBarButtonItem()

        super.pushViewController(viewController, animated: animated)
    }

}
