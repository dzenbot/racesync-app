//
//  OnboardInterfaceController.swift
//  RaceSyncWatch Extension
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-26.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import WatchKit
import UIKit

class OnboardInterfaceController: WKInterfaceController {

    @IBOutlet var messageLabel: WKInterfaceLabel?

    override func awake(withContext context: Any?) {
        WatchSessionManager.sharedManager.add(self)
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }
}

extension OnboardInterfaceController: WatchSessionManagerDelegate {

    func sessionDidReceiveUserContext(_ model: UserViewModel) {
        dismiss()
    }
}
