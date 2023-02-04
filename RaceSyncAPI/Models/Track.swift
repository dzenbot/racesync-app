//
//  Track.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-11-29.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class Track: ImmutableMappable, Descriptable {

    public let id: ObjectId
    public let title: String
    public let description: String?
    public let videoUrl: String?
    public let leaderboardUrl: String?
    public let validationFeetUrl: String?
    public let validationMetersUrl: String?
    public let startDate: Date?
    public let endDate: Date?
    public let userName: String?
    public let raceClass: RaceClass
    public let elements: [TrackElement]

    // MARK: - Initialization

    required public init(map: Map) throws {
        id = try map.value(ParamKey.id)
        title = try map.value(ParamKey.title)
        description = try map.value(ParamKey.description)
        videoUrl = try? map.value(ParamKey.videoUrl)
        leaderboardUrl = try map.value(ParamKey.leaderboardUrl)
        validationFeetUrl = try? map.value(ParamKey.validationFeetUrl)
        validationMetersUrl = try? map.value(ParamKey.validationMetersUrl)
        startDate = try? map.value(ParamKey.startDate, using: MapperUtil.dateTransform)
        endDate = try? map.value(ParamKey.endDate, using: MapperUtil.dateTransform)
        userName = try map.value(ParamKey.userName)
        raceClass = try map.value(ParamKey.raceClass, using: EnumTransform<RaceClass>())
        elements = try map.value(ParamKey.elements)
    }

    public var elementsCount: Int {
        get {
            var count: Int = 0
            if elements.count == count { return count } //preventively return zero
            
            for e in elements {
                if e.count > 0 {
                    count += e.count
                }
            }
            return count
        }
    }
}

public enum TrackType: String, EnumTitle {
    case gq, utt, champs, canada

    public var title: String {
        switch self {
        case .gq:       return "Global Qualifier (GQ)"
        case .utt:      return "Universal Time Trial (UTT)"
        case .champs:   return "MultiGP Drone Racing Championship"
        case .canada:   return "Canadian Series"
        }
    }
}

public struct TrackElement: ImmutableMappable, Descriptable {
    public let type: TrackElementType
    public let count: Int

    // MARK: - Initialization

    public init(map: Map) throws {
        type = try map.value(ParamKey.type)
        count = try map.value(ParamKey.count)
    }
}

public enum TrackElementType: String, EnumTitle {
    case gate = "gate"
    case flag = "flag"
    case towerGate = "tower_gate"
    case doubleGate = "double_gate"
    case ladderGate = "ladder_gate"
    case toplessLadder = "topless_ladder_gate"
    case offsetGate = "offset_gate"
    case diveGate = "dive_gate"
    case launchGate = "launch_gate"
    case hurdle = "hurdle"
    case splits = "split_s"
    case megaGate = "mega_gate"
    case tinyGate = "tiny_gate"

    public var title: String {
        switch self {
        case .gate:             return "Gate"
        case .flag:             return "Flag"
        case .towerGate:        return "Tower"
        case .doubleGate:       return "Double Gate"
        case .ladderGate:       return "Ladder"
        case .toplessLadder:    return "Topless Ladder"
        case .offsetGate:       return "Offset Gate"
        case .diveGate:         return "Dive Gate"
        case .launchGate:       return "Launch Gate"
        case .hurdle:           return "Hurdle"
        case .splits:           return "Split-S Gate"
        case .megaGate:         return "Mega Gate"
        case .tinyGate:         return "Tiny Gate"
        }
    }
}
