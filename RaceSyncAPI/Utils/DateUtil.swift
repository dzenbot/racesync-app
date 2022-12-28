//
//  DateUtil.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-19.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation

public class DateUtil {

    public static var standardDateFormatter: DateFormatter = {
        let dateFormater: DateFormatter = DateFormatter()
        dateFormater.dateFormat = StandardDateTimeFormat
        return dateFormater
    }()

    public static func deserializeJSONDate(_ jsonDate: String) -> Date? {
        return standardDateFormatter.date(from: jsonDate)
    }

    public static func localizedString(from date: Date?, full: Bool = false) -> String? {
        guard let date = date else { return nil }

        if full {
            if date.isInThisYear {
                return displayFullDateTimeFormatter.string(from: date)
            } else {
                return displayFullDateTimeYearFormatter.string(from: date)
            }
        }
        else if date.isInThisYear || date.timeIntervalSinceNow.sign == .plus {
            return displayDateTimeFormatter.string(from: date)
        } else {
            return displayDateFormatter.string(from: date)
        }
    }
}

public extension DateUtil {

    static let displayFullDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d @ h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }()

    static let displayFullDateTimeYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy @ h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }()

    static let displayDateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE, MMM d @ h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }()

    static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter
    }()
}
