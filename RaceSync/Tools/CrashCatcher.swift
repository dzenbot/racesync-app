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
        SentrySDK.start { options in
            options.dsn = Self.SentryClientDSN
            options.debug = true // Enabled debug when first installing is always helpful

            // Enable all experimental features
            options.attachViewHierarchy = true
            options.enablePreWarmedAppStartTracing = true
            options.enableTimeToFullDisplayTracing = true
            options.swiftAsyncStacktraces = true
        }
    }

    static func setupUser(_ id: ObjectId, username: String) {
        let user = User()
        user.userId = id
        user.username = username
        SentrySDK.setUser(user)
    }

    static func invalidateUser() {
        SentrySDK.setUser(nil)
    }

    private static let SentryClientDSN = "https://4dbd7fdde60b4c828846d94fecc814c1@sentry.io/3036524"
}

