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
            Client.shared = try Client(dsn: "https://4dbd7fdde60b4c828846d94fecc814c1@sentry.io/3036524")
            try Client.shared?.startCrashHandler()
        } catch let error {
            Clog.log("\(error)", andLevel: .error)
        }
    }
}
