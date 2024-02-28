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

struct CalendarEvent {
    let title: String
    let location: String
    let description: String
    let startDate: Date
    let endDate: Date?
    let url: URL?
}

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
            ekevent.endDate = event.endDate ?? event.startDate
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
