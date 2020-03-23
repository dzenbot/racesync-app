//
//  EventCatcher.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-03-09.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI

class EventTracker {

    static func configure() {
        configureAnalytics()
        configureRater()
    }

    // MARK: - Analytics

    fileprivate static let isAnalyticsEnabled: Bool = false
    fileprivate static let showLogs: Bool = true

    fileprivate static func configureAnalytics() {
        guard isAnalyticsEnabled, let gai = GAI.sharedInstance() else {
            return
        }

        gai.tracker(withTrackingId: StringConstants.GoogleAnalyticsID)
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

    // MARK: - AppStore Rater

    fileprivate static func configureRater() {
        let rater = RateMe.sharedInstance
        rater.debug = false
        rater.showPreview = false

        // Interval configs
        rater.usesUntilPrompt = 10
        rater.daysUntilPrompt = 5
        rater.eventsUntilPrompt = 3
        rater.daysBeforeReminding = 7
        rater.shouldPromptIfRated = true
        rater.showNeverRemindButton = false
        rater.shouldPrompAtLaunch = false

        // Content configs
        rater.appId = StringConstants.ApplicationID
        rater.applicationName = Bundle.main.applicationName
        rater.reviewTitle = "Rate \(Bundle.main.applicationName)"
        rater.reviewMessage = "Please take a moment to rate and review the app on the App Store.\n\nThank you for your support!"
        rater.rateButtonTitle = "Rate Now"
        rater.remindButtonTitle = "Maybe Later"
    }
}
