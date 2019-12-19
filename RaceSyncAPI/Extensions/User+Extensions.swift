//
//  User+Extensions.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-12.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation

public extension User {

    var isMe: Bool {
        guard let myUser = APIServices.shared.myUser else { return false }
        return id == myUser.id
    }

}
