//
//  NewRaceForm.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2022-12-27.
//  Copyright © 2022 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI

enum RaceFormMode: Int {
    case new, update
}

enum RaceFormSection: Int {
    case general, specific //, frequencies

    public var header: String {
        switch self {
        case .general:      return "General Details "
        case .specific:     return "Specific Details"
        // TODO: Implement Video Frequency Profile selection (may need new API support)
        //case .frequencies:  return "Video Frequencies"
        }
    }

    public var footer: String? {
        switch self {
        case .general:      return "* Required fields"
        case .specific:     return "** Broadcasts a notification to all chapter members."
        }
    }
}

enum RaceFormRow: Int, EnumTitle {
    case name, startDate, endDate, chapter, `class`, format, schedule, privacy, status,
         scoring, timing, rounds, season, location, shortDesc, longDesc, itinerary, notify

    public var title: String {
        switch self {
        case .name:         return "Name"
        case .startDate:    return "Start Date"
        case .endDate:      return "End Date"
        case .chapter:      return "Chapter"
        case .class:        return "Class"
        case .format:       return "Format"
        case .schedule:     return "Schedule"
        case .privacy:      return "Privacy"
        case .status:       return "Status"

        case .scoring:      return "Fun Fly (Disable Scoring)"
        case .timing:       return "Time Capturing"
        case .rounds:       return "Rounds/Pack count"
        case .season:       return "Season"
        case .location:     return "Location"
        case .shortDesc:    return "Short Description"
        case .longDesc:     return "Description"
        case .itinerary:    return "Itinerary"
        case .notify:       return "Send Notification? **"
        }
    }
}

extension RaceFormRow {

    func value(from raceData: RaceData) -> String? {
        switch self {
        case .name:
            return raceData.name
        case .startDate:
            if let date = raceData.startDate {
                return DateUtil.localizedString(from: date)
            }
            return nil
        case .endDate:
            if let date = raceData.endDate {
                return DateUtil.localizedString(from: date)
            }
            return nil
        case .chapter:
            return raceData.chapterName
        case .class:
            return RaceClass(rawValue: raceData.raceClass)?.title
        case .format:
            return ScoringFormat(rawValue: raceData.format)?.title
        case .schedule:
            return QualifyingType(rawValue: raceData.qualifying)?.title
        case .privacy:
            return EventType(rawValue: raceData.privacy)?.title
        case .status:
            return RaceStatus(rawValue: raceData.status)?.title
        case .scoring:
            return raceData.funfly ? "" : nil // will be converted to Bool
        case .timing:
            return raceData.timing ? "" : nil // will be converted to Bool
        case .rounds:
            return "\(raceData.rounds)"
        case .season:
            return raceData.seasonName
        case .location:
            return raceData.courseName
        case .shortDesc:
            if let text = raceData.shortDesc, text.count > 0 {
                return text.stripHTML(true).safeSubstring(to: 20).capitalized + "…"
            }
            return nil
        case .longDesc:
            if let text = raceData.longDesc, text.count > 0 {
                return text.stripHTML(true).safeSubstring(to: 20).capitalized + "…"
            }
            return nil
        case .itinerary:
            if let text = raceData.itinerary, text.count > 0 {
                return text.stripHTML(true).safeSubstring(to: 20).capitalized + "…"
            }
            return nil
        case .notify:
            return raceData.sendNotification ? "" : nil // will be converted to Bool
        }
    }

    var isRowRequired: Bool {
        switch self {
        case .name, .startDate:
            return true
        default:
            return false
        }
    }

    func requiredValue(from data: RaceData) -> String? {
        switch self {
        case .name:         return data.name
        case .startDate:    return data.startDateString
        default:            return nil
        }
    }

    var formType: FormType {
        switch self {
        case .name:
            return .textfield
        case .startDate, .endDate:
            return .datePicker
        case .scoring, .timing, .notify:
            return .switch
        case .shortDesc, .longDesc, .itinerary:
            return .textEditor
        default:
            return .textPicker
        }
    }
}
