//
//  NSDate+Extensions.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-12.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation

public extension Date {

    func isInSameWeek(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .weekOfYear)
    }

    func isInSameMonth(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .month)
    }

    func isInSameYear(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .year)
    }

    func isInSameDay(date: Date) -> Bool {
        return Calendar.current.isDate(self, equalTo: date, toGranularity: .day)
    }

    var isInThisYear: Bool {
        return isInSameYear(date: Date())
    }

    var isInThisWeek: Bool {
        return isInSameWeek(date: Date())
    }

    var isInYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }

    var isInToday: Bool {
        return Calendar.current.isDateInToday(self)
    }

    var isInPastDay: Bool {
        let diff = abs(Date().timeIntervalSince(self))
        return diff <= (60 * 60 * 24)
    }

    var isInPastHour: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .hour)
    }

    var isInSameWeek: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }

    func daysFromNow() -> Int {
        return Int(abs(ceil(self.timeIntervalSinceNow / (60 * 60 * 24))))
    }

    func minuteFromNow() -> Int {
        return Int(ceil(self.timeIntervalSinceNow / 60))
    }

}
