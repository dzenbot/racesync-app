//
//  CalendarUtil.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-14.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import EventKit
import RaceSyncAPI

class CalendarUtil {

    static func add(_ event: CalendarEvent) {
        let eventStore = EKEventStore()

        eventStore.requestAccess(to: .event) { (granted, error) in
            guard granted else { return }

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
                Clog.log("error saving to calendar: \(error.localizedDescription)")
            }
        }
    }
}

extension Race {

    var calendarEvent: CalendarEvent? {
        guard let startDate = startDate, let address = address, let raceUrl = URL(string: url) else {
            return nil
        }

        guard startDate.timeIntervalSinceNow.sign == .plus else {
            return nil
        }

        return CalendarEvent(title: name, location: address, description: description, startDate: startDate, url: raceUrl)

    }
}

struct CalendarEvent {
    let title: String
    let location: String
    let description: String
    let startDate: Date
    let url: URL?
}
