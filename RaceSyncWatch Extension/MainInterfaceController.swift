//
//  InterfaceController.swift
//  RaceSyncWatch Extension
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-25.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import WatchKit
import UIKit

class MainInterfaceController: WKInterfaceController {

    @IBOutlet var nameLabel: WKInterfaceLabel?
    @IBOutlet var idLabel: WKInterfaceLabel?

    @IBOutlet var avatarImageView: WKInterfaceImage?
    @IBOutlet var qrImageView: WKInterfaceImage?

    override func awake(withContext context: Any?) {
        if let userInfo = WatchSessionManager.shared.storedUserInfo, let model = UserViewModel(userInfo) {
            updateInterface(with: model)
        } else {
            presentController(withName: String(describing: OnboardInterfaceController.self), context: context)
        }

        WatchSessionManager.shared.add(self)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

    func updateInterface(with model: UserViewModel) {
        idLabel?.setText(model.id)
        nameLabel?.setText(model.name)
        qrImageView?.setImage(model.qrImg)

        if let img = model.avatarImg {
            avatarImageView?.setImage(img)
        } else {
            avatarImageView?.setImage(UIImage(named: "watch_placeholder_small"))
        }
    }
}

extension MainInterfaceController: WatchSessionManagerDelegate {

    func sessionDidReceiveUserContext(_ model: UserViewModel) {
        updateInterface(with: model)
    }
}
