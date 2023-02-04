//
//  CrashCatcher.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-20.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI
import Sentry

class CrashCatcher {

    static func configure() {
        // Create a Sentry client and start crash handler
        do {
            Client.shared = try Client(dsn: Self.SentryClientDSN)
            try Client.shared?.startCrashHandler()
        } catch let error {
            Clog.log("\(error)", andLevel: .error)
        }
    }

    static func setupUser(_ id: ObjectId, username: String) {
        let user = User(userId: id)
        user.username = username

        Client.shared?.user = user
    }

    static func invalidateUser() {
        Client.shared?.user = nil
    }

    private static let SentryClientDSN = "https://4dbd7fdde60b4c828846d94fecc814c1@sentry.io/3036524"
}

