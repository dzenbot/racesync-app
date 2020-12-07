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

public enum TrackClass: String {
    case open = "0"
    case mega = "1"
    case micro = "2"
    case tiny = "3"

    var title: String {
        switch self {
        case .open:     return "Open"
        case .mega:     return "Mega"
        case .micro:    return "Micro"
        case .tiny:     return "Tiny"
        }
    }
}

public class Track: ImmutableMappable, Descriptable {

    public let id: ObjectId
    public let title: String
    public let leaderboardUrl: String
    public let `type`: TrackType
    public let `class`: TrackClass
    public let designer: String
    public let elements: TrackElements?

    public let isUTT: Bool
    public let isGQ: Bool
    public let isMega: Bool

    // MARK: - Initialization

    required public init(map: Map) throws {
        id = try map.value("id")
        title = try map.value("title")
        leaderboardUrl = try map.value("leaderboardUrl")
        designer = try map.value("designer") ?? ""
        elements = try map.value("elements")

        `type` = try map.value("type")
        `class` = try map.value("class")

        isUTT = (`type` == .utt)
        isGQ = (`type` == .gq)
        isMega = (`class` == .mega)
    }
}

public struct TrackElements: ImmutableMappable, Descriptable {

    let gates: Int
    let flags: Int
    let doubleGates: Int
    let ladderGates: Int
    let toplessLadderGates: Int
    let diveGates: Int
    let launchGates: Int
    let hurtles: Int

    public init(map: Map) throws {
        gates = try map.value("gates") ?? 0
        flags = try map.value("flags") ?? 0
        doubleGates = try map.value("tower_gates") ?? 0
        ladderGates = try map.value("ladder_gates") ?? 0
        toplessLadderGates = try map.value("topless_ladder_gates") ?? 0
        diveGates = try map.value("dive_gates") ?? 0
        launchGates = try map.value("launch_gates") ?? 0
        hurtles = try map.value("hurtles") ?? 0
    }
}
