//
//  SafariActivity.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-13.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import TUSafariActivity

class SafariActivity: TUSafariActivity {

    override var activityTitle: String? {
        return "Open in Safari"
    }

    override var activityImage: UIImage? {
        return UIImage(named: "icn_safari_activity")
    }
}
