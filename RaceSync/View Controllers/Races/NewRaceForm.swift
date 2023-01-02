//
//  NewRaceForm.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2022-12-27.
//  Copyright © 2022 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI

enum NewRaceMode: Int {
    case create, edit
}

enum NewRaceSection: Int, EnumTitle, CaseIterable {
    case general, specific //, frequencies

    public var title: String {
        switch self {
        case .general:      return "General Details "
        case .specific:     return "Specific Details"
        //case .frequencies:  return "Video Frequencies"
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

        case .scoring:      return "Fun Fly (Disable Scoring)"
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
            if let string = raceData.date, let date = DateUtil.isoDateFormatter.date(from: string) {
                return DateUtil.localizedString(from: date)
            }
            return nil
        case .chapter:
            return raceData.chapterName
        case .class:
            return RaceClass(rawValue: raceData.class)?.title
        case .format:
            return ScoringFormats(rawValue: raceData.format)?.title
        case .schedule:
            return RaceSchedule(rawValue: raceData.schedule)?.title
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
            return raceData.locationName
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

    var formType: FormType {
        switch self {
        case .name:
            return .textfield
        case .date:
            return .datePicker
        case .scoring, .timing:
            return .switch
        case .shortDesc, .longDesc, .itinerary:
            return .textview
        default:
            return .textPicker
        }
    }
}
