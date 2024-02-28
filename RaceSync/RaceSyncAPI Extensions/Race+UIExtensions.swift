//
//  Race+UIExtensions.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2023-01-16.
//  Copyright © 2023 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI

extension Race {

    var calendarEvent: CalendarEvent? {
        guard let startDate = startDate, let address = address, let raceUrl = URL(string: url) else {
            return nil
        }
        guard startDate.timeIntervalSinceNow.sign == .plus else {
            return nil
        }
        return CalendarEvent(title: name, location: address, description: description, startDate: startDate, endDate: endDate, url: raceUrl)
    }
}
