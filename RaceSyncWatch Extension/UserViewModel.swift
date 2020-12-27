//
//  UserViewModel.swift
//  RaceSyncWatch Extension
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-26.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import WatchKit
import UIKit

class UserViewModel: NSObject {
    let id: String
    let name: String

    let avatarImg: UIImage?
    let qrImg: UIImage

    init?(_ payload: [String : Any]) {
        guard let id = payload["id"] as? String else { return nil }
        guard let name = payload["name"] as? String else { return nil }
        guard let qrData = payload["qr-data"] as? Data, let qrImg = UIImage(data: qrData) else { return nil }

        self.id = id
        self.name = name
        self.qrImg = qrImg

        if let data = payload["avatar-data"] as? Data {
            self.avatarImg = UIImage(data: data)
        } else {
            self.avatarImg = nil
        }

        super.init()
    }
}
