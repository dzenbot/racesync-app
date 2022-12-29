//
//  NewRaceForm.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2022-12-27.
//  Copyright © 2022 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI

enum NewRaceSection: Int, EnumTitle, CaseIterable {
    case general, specific, frequencies

    public var title: String {
        switch self {
        case .general:      return "General Details "
        case .specific:     return "Specific Details"
        case .frequencies:  return "Video Frequencies"
        }
    }
}

enum NewRaceRow: Int, EnumTitle, CaseIterable {
    case name, date, chapter, `class`, format, schedule, privacy, status,
         scoring, timing, rounds, season, location, shortDesc, longDesc, itinerary

    public var title: String {
        switch self {
        case .name:         return "Name"
        case .date:         return "Start Date"
        case .chapter:      return "Chapter"
        case .class:        return "Race Class"
        case .format:       return "Race Format"
        case .schedule:     return "Schedule"
        case .privacy:      return "Event Privacy"
        case .status:       return "Status"

        case .scoring:      return "Fun Fly"
        case .timing:       return "Time Capturing"
        case .rounds:       return "Rounds/Pack count"
        case .season:       return "Season"
        case .location:     return "Location"
        case .shortDesc:    return "Short Description"
        case .longDesc:     return "Long Description"
        case .itinerary:    return "Itinerary Content"
        }
    }
}

extension NewRaceRow {

    func displayText(from raceData: RaceData) -> String? {
        switch self {
        case .name:
            return raceData.name
        case .date:
            if let string = raceData.date, let date = DateUtil.standardDateFormatter.date(from: string) {
                return DateUtil.localizedString(from: date)
            }
            return nil
        case .chapter:
            return raceData.chapterName
        case .class:
            if let value = raceData.class {
                return RaceClass(rawValue: value)?.title
            }
            return nil
        case .format:
            if let value = raceData.format {
                return ScoringFormats(rawValue: value)?.title
            }
            return nil
        case .schedule:
            return raceData.schedule
        case .privacy:
            if let value = raceData.privacy {
                return EventType(rawValue: value)?.title
            }
            return nil
        case .status:
            return raceData.status
        default:
            return nil
        }
    }

    var isRowRequired: Bool {
        switch self {
        case .name, .date:
            return true
        default:
            return false
        }
    }

    func requiredValue(from data: RaceData) -> String? {
        switch self {
        case .name:     return data.name
        case.date:      return data.date
        default:        return nil
        }
    }

    var defaultValue: String? {
        switch self {
        case .name, .date, .chapter:
            return nil
        case .class:
            return RaceClass.open.rawValue
        case .format:
            return ScoringFormats.fastest3Laps.rawValue
        case .schedule:
            return RaceSchedule.controlled.rawValue
        case .privacy:
            return EventType.public.rawValue
        case .status:
            return RaceStatus.closed.rawValue
        default:
            return nil
        }
    }

    var formType: FormType {
        switch self {
        case .name:
            return .textfield
        case .date:
            return .datePicker
        case .scoring, .timing:
            return .textfield
        case .shortDesc, .longDesc, .itinerary:
            return .textview
        default:
            return .textPicker
        }
    }
}
