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
        configureRater()
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
