//
//  CalendarActivity.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-13.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import EventKit

class CalendarActivity: UIActivity {

    // MARK: - Private Variables

    var event: CalendarEvent?

    // MARK: - UIActivity Override

    override var activityType: UIActivity.ActivityType? {
        return ActivityType(String(describing: self))
    }

    override var activityTitle: String? {
        return "Save to Calendar"
    }

    override var activityImage: UIImage? {
        return UIImage(named: "icn_activity_calendar")
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {

        let status: EKAuthorizationStatus = EKEventStore.authorizationStatus(for: .event)

        for item in activityItems {
            if item is CalendarEvent && (status == .notDetermined || status == .authorized) {
                return true
            }
        }

        return false
    }

    override func prepare(withActivityItems activityItems: [Any]) {

        for item in activityItems {
            if let event = item as? CalendarEvent {
                self.event = event
            }
        }
    }

    override func perform() {

        if let event = event {
            CalendarUtil.add(event)
        }

        activityDidFinish(true)
    }
}
