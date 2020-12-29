//
//  UserViewModel.swift
//  RaceSyncWatch Extension
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-26.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import WatchKit
import UIKit

class WatchUser: NSObject {
    let id: String
    let name: String
    let qrImg: UIImage
    let avatarImg: UIImage?

    init?(_ payload: [String : Any]) {
        guard let id = payload[WParameterKey.id] as? String else { return nil }
        guard let name = payload[WParameterKey.name] as? String else { return nil }
        guard let qrData = payload[WParameterKey.qrData] as? Data, let qrImg = UIImage(data: qrData) else { return nil }

        self.id = id
        self.name = name
        self.qrImg = qrImg

        if let data = payload[WParameterKey.avatarData] as? Data {
            self.avatarImg = UIImage(data: data)
        } else {
            self.avatarImg = nil
        }

        super.init()
    }
}
