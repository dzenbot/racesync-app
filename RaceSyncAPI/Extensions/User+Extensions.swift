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

    func hasJoined(_ race: Race) -> Bool {
        guard let raceEntries = race.entries else { return false }

        return raceEntries.contains(where: { (entry) -> Bool in
            return entry.pilotId == id
        })
    }
}
