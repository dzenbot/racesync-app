//
//  Track.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-11-29.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper
import RaceSyncAPI

public enum TrackType: String {
    case gq = "0"
    case utt = "1"
    case io = "2"
    case champs = "3"
    case canada = "4"

    var title: String {
        switch self {
        case .gq:       return "Global Qualifier (GQ)"
        case .utt:      return "Universal Time Trial (UTT)"
        case .io:       return "International Open"
        case .champs:   return "Championship"
        case .canada:   return "Canadian Series"
        }
    }
}

public enum TrackClass: String, EnumTitle {
    case open = "0"
    case mega = "1"
    case micro = "2"
    case tiny = "3"

    public var title: String {
        switch self {
        case .open:     return "Open"
        case .mega:     return "Mega"
        case .micro:    return "Micro"
        case .tiny:     return "Tiny Whoop"
        }
    }
}

public class Track: ImmutableMappable, Descriptable {

    public let id: ObjectId
    public let title: String
    public let videoUrl: String?
    public let leaderboardUrl: String?
    public let designer: String?
    public let `type`: TrackType
    public let `class`: TrackClass
    public let elements: [TrackElement]

    public let isUTT: Bool
    public let isGQ: Bool
    public let isMega: Bool

    // MARK: - Initialization

    required public init(map: Map) throws {
        id = try map.value("id")
        title = try map.value("title")
        videoUrl = try map.value("video_url")
        leaderboardUrl = try map.value("leaderboard_url")
        designer = try map.value("designer")
        elements = try map.value("elements")

        `type` = try map.value("type")
        `class` = try map.value("class")

        isUTT = (`type` == .utt)
        isGQ = (`type` == .gq)
        isMega = (`class` == .mega)
    }

    var elementsCount: Int {
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
    let type: TrackElementType
    let count: Int

    // MARK: - Initialization

    public init(map: Map) throws {
        type = try map.value("type")
        count = try map.value("count")
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

    public func title(with count: Int) -> String {
        var string = self.title
        if count > 1 { string += "s" }
        return string
    }

    public var image: UIImage? {
        return UIImage(named: "track_element_\(self.rawValue)")
    }
}
