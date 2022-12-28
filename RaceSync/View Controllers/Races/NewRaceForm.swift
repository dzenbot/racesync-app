//
//  NewRaceForm.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2022-12-27.
//  Copyright © 2022 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI

enum NewRaceRow: Int, EnumTitle, CaseIterable {
    case name, date, chapter, `class`, format, schedule, privacy, status

    public var title: String {
        switch self {
        case .name:     return "Name"
        case .date:     return "Start Date"
        case .chapter:  return "Chapter"
        case .class:    return "Race Class"
        case .format:   return "Race Format"
        case .schedule: return "Schedule"
        case .privacy:  return "Event Privacy"
        case .status:   return "Status"
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

    func value(from data: RaceData) -> String? {
        switch self {
        case .name:
            return data.name
        default:
            return nil
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
        }
    }
}
