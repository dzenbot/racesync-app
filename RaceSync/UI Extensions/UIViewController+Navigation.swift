//
//  UIViewController+Navigation.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2021-10-21.
//  Copyright © 2021 MultiGP Inc. All rights reserved.
//

import UIKit

extension UIViewController {

    var topOffset: CGFloat {
        get {
            let status_height = UIApplication.shared.statusBarFrame.height
            let navi_height = navigationController?.navigationBar.frame.size.height ?? 44
            return status_height + navi_height
        }
    }
}
