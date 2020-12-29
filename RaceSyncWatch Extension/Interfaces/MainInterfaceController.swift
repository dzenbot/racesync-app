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

    var isVisible: Bool = false

    override func awake(withContext context: Any?) {
        if let user = WatchSessionManager.shared.cachedUser {
            updateInterface(with: user)
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

    override func didAppear() {
        isVisible = true
    }

    override func willDisappear() {
        isVisible = false
    }

    func updateInterface(with user: WatchUser) {
        idLabel?.setText(user.id)
        nameLabel?.setText(user.name)
        qrImageView?.setImage(user.qrImg)

        if let img = user.avatarImg {
            avatarImageView?.setImage(img)
        } else {
            avatarImageView?.setImage(UIImage(named: "watch_placeholder_small"))
        }
    }

    func invalidateInterface() {
        idLabel?.setText(nil)
        nameLabel?.setText(nil)
        qrImageView?.setImage(nil)
        avatarImageView?.setImage(nil)
    }
}

extension MainInterfaceController: WatchSessionManagerDelegate {

    func sessionDidReceiveUserContext(_ user: WatchUser) {
        updateInterface(with: user)
    }

    func sessionWasInvalidated() {
        invalidateInterface()

        if isVisible {
            presentController(withName: String(describing: OnboardInterfaceController.self), context: nil)
        }
    }
}
