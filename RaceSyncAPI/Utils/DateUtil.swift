//
//  DateUtil.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-19.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation

public class DateUtil {

    fileprivate static let standardFormat: String = "yyyy-MM-dd h:mm a"

    fileprivate static let displayFullDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM dd @ h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }()

    fileprivate static let displayDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE MMM dd @ h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }()

    fileprivate static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter
    }()

    public static func deserializeJSONDate(_ jsonDate: String) -> Date? {
        let dateFor: DateFormatter = DateFormatter()
        dateFor.dateFormat = standardFormat
        return dateFor.date(from: jsonDate)
    }

    public static func localizedString(from date: Date?, full: Bool = false) -> String? {
        guard let date = date else { return nil }

        if full {
            return displayFullDateTimeFormatter.string(from: date)
        }
        else if date.isInSameYear(date: Date()) {
            return displayDateTimeFormatter.string(from: date)
        } else {
            return displayDateFormatter.string(from: date)
        }
    }
}
