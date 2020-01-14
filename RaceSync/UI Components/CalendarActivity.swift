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
        return UIImage(named: "icn_calendar_activity")
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

        let eventStore = EKEventStore()

        eventStore.requestAccess(to: .event) { [weak self] (granted, error) in
            guard granted, let event = self?.event else { return }

            let ekevent = EKEvent(eventStore: eventStore)
            ekevent.title = event.title
            ekevent.location = event.location
            ekevent.notes = event.description
            ekevent.startDate = event.startDate
            ekevent.endDate = event.startDate
            ekevent.isAllDay = false
            ekevent.url = event.url

            ekevent.calendar = eventStore.defaultCalendarForNewEvents

            do {
                try eventStore.save(ekevent, span: .thisEvent)
            }  catch {
                print("error saving to calendar: \(error.localizedDescription)")
            }
        }

        activityDidFinish(true)
    }
}

struct CalendarEvent {
    let title: String
    let location: String
    let description: String
    let startDate: Date
    let url: URL?
}
