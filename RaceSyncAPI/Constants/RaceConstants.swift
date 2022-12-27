//
//  RaceConstants.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-22.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation

public enum RaceType: String, EnumTitle {
    case normal = "1"
    case qualifier = "2"
    case final = "3"

    public var title: String {
        switch self {
        case .normal:       return "Normal"
        case .qualifier:    return "Qualifiers"
        case .final:        return "Championship"
        }
    }
}

public enum RaceStatus: String {
    case opened = "Opened"
    case closed = "Closed"
}

public enum RaceOfficialStatus: String {
    case normal = "0"
    case requested = "1"
    case approved = "2"
}

//SCORING_FORMATS = array(0=>'Aggregate Laps', 1=>'Fastest Lap', 6=>'Fastest 2 Consecutive Laps', 2=>'Fastest 3 Consecutive Laps')
public enum ScoringFormats: String, EnumTitle {
    case aggregate = "0"
    case fastestLap = "1"
    case fastest2Laps = "6"
    case fastest3Laps = "2"

    public var title: String {
        switch self {
        case .aggregate:        return "Aggregate Laps"
        case .fastestLap:       return "Fastest Lap"
        case .fastest2Laps:     return "Fastest 2 Consecutive Laps"
        case .fastest3Laps:     return "Fastest 3 Consecutive Laps"
        }
    }
}

//RACE_CLASS = array(0 =>'Open', 1 =>'Tiny Whoop', 2 =>'Micro (Tiny Trainer)', 3 =>'Freedom Spec', 4 =>'Street League', 5 =>'Mega', 6 =>'Velocidrone')
public enum RaceClass: String, EnumTitle {
    case open = "0"
    case whoop = "1"
    case micro = "2"
    case freedom = "3"
    case street = "4"
    case mega = "5"
    case velo = "6"

    public var title: String {
        switch self {
        case .open:         return "Open"
        case .whoop:        return "Tiny Whoop"
        case .micro:        return "Micro (Tiny Trainer)"
        case .freedom:      return "Freedom Spec"
        case .street:       return "Street League"
        case .mega:         return "Mega"
        case .velo:         return "Velocidrone"
        }
    }
}

