//
//  User+Extensions.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-12.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation

public extension User {

    /**
     Convenience to identify if a User is the current signed in user.
     */
    var isMe: Bool {
        guard let myUser = APIServices.shared.myUser else { return false }
        return id == myUser.id
    }

    /**
     Convenience to identify if a multigp.com User is part of the development team, to show special dev tools such as API environment switch, feature flags and more.
     Add your MGP user id to the list.
     */
    var isDevTeam: Bool {
        let ids = [
            "20676",    // Ignacio "Zenith" Romero
            "96",       // Roger "Focus" Bess
            "2145",     // Mark "2dogrc" Grohe
            "7327",     // Tim "DoALoop" Barnhart
            "35435"     // Henry "MrOizoFPV" Moizo
        ]

        return ids.contains(where: { (someId) -> Bool in
            return someId == id
        })
    }

    /**
     Convenience to identify if a user has joined a specific race.
     */
    func hasJoined(_ race: Race) -> Bool {
        guard let raceEntries = race.entries else { return false }

        return raceEntries.contains(where: { (entry) -> Bool in
            return entry.pilotId == id
        })
    }
}
