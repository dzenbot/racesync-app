//
//  UITabBarController+Extensions.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-11.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

extension UITabBarController {

    func preloadTabs() {
        if let vcs = viewControllers {
            for vc in vcs {
                let _ = vc.view
            }
        }
    }
}
