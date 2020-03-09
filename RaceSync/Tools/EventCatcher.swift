//
//  EventCatcher.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-03-09.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI

class EventCatcher {

    static let showLogs: Bool = false

    static func configure() {
        guard let gai = GAI.sharedInstance() else {
            Clog.log("Google Analytics not configured correctly")
            return
        }
        
        gai.tracker(withTrackingId: "224684788")
        // Optional: automatically report uncaught exceptions.
        gai.trackUncaughtExceptions = true

        // Optional: set Logger to VERBOSE for debug information.
        // Remove before app release.
        #if DEBUG
        if showLogs {
            gai.logger.logLevel = .verbose
        }
        #endif
    }

    static func trackScreenView(withName name: String) {
        let gai = GAI.sharedInstance()

        guard let tracker = gai?.defaultTracker else { return }
        tracker.set(kGAIScreenName, value: name)

        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])

        gai?.dispatch()

        Clog.log("Tracking Screen with name : \(name)")
    }
}
