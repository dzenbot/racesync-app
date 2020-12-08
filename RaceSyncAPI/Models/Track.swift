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
    public let videoUrl: String?
    public let leaderboardUrl: String?
    public let validationFeetUrl: String?
    public let validationMetersUrl: String?
    public let startDate: Date?
    public let endDate: Date?
    public let designer: String?
    public let `class`: TrackClass
    public let elements: [TrackElement]

    // MARK: - Initialization

    required public init(map: Map) throws {
        id = try map.value("id")
        title = try map.value("title")
        videoUrl = try? map.value("videoUrl")
        leaderboardUrl = try map.value("leaderboardUrl")
        validationFeetUrl = try? map.value("validationFeetUrl")
        validationMetersUrl = try? map.value("validationMetersUrl")
        startDate = try? map.value("startDate", using: MapperUtil.dateTransform)
        endDate = try? map.value("endDate", using: MapperUtil.dateTransform)
        designer = try map.value("designer")
        `class` = try map.value("class", using: EnumTransform<TrackClass>())
        elements = try map.value("elements")
    }

    public var elementsCount: Int {
        get {
            var count: Int = 0

            for e in elements {
                if e.count > 0 {
                    count += e.count
                }
            }
            return count
        }
    }
}

public struct TrackElement: ImmutableMappable, Descriptable {
    public let type: TrackElementType
    public let count: Int

    // MARK: - Initialization

    public init(map: Map) throws {
        type = try map.value("type")
        count = try map.value("count")
    }
}

public enum TrackType: String, EnumTitle {
    case gq, utt, canada

    public var title: String {
        switch self {
        case .gq:       return "Global Qualifier (GQ)"
        case .utt:      return "Universal Time Trial (UTT)"
        case .canada:   return "Canadian Series"
        }
    }
}

public enum TrackClass: String, EnumTitle {
    case open = "0"
    case mega = "1"
    case tiny = "2"

    public var title: String {
        switch self {
        case .open:     return "Open"
        case .mega:     return "Mega"
        case .tiny:     return "Tiny Whoop"
        }
    }
}

public enum TrackElementType: String, EnumTitle {
    case gate = "gate"
    case flag = "flag"
    case towerGate = "tower_gate"
    case doubleGate = "double_gate"
    case ladderGate = "ladder_gate"
    case toplessLadderGate = "topless_ladder_gate"
    case diveGate = "dive_gate"
    case launchGate = "launch_gate"
    case hurtle = "hurtle"
    case splits = "split_s"
    case megaGate = "mega_gate"
    case tinyGate = "tiny_gate"

    public var title: String {
        switch self {
        case .gate:             return "Gate"
        case .flag:             return "Flag"
        case .towerGate:        return "Tower Gate"
        case .doubleGate:       return "Double Gate"
        case .ladderGate:       return "Ladder Gate"
        case .toplessLadderGate:return "Topless Ladder Gate"
        case .diveGate:         return "Dive Gate"
        case .launchGate:       return "Launch Gate"
        case .hurtle:           return "Hurtle"
        case .splits:           return "Split-S Gate"
        case .megaGate:         return "Mega Gate"
        case .tinyGate:         return "Tiny Gate"
        }
    }
}
