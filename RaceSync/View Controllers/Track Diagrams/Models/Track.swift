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
    case general = "0"
    case utt = "1"
    case gq = "2"
}

public enum TrackClass: String {
    case open = "0"
    case mega = "1"
    case micro = "2"
    case tiny = "3"
}

public enum TrackElement: String {
    case gate = "0"
    case flag = "1"
    case tower_gate = "2"
    case double_gate = "3"
    case ladder_gate = "4"
    case topless_ladder_gate = "5"
    case dive_gate = "6"
    case launch_gate = "7"
    case hurtle = "8"
}

public struct TrackElements {
    let gate: Int
    let flag: Int
    let tower_gate: Int
    let double_gate: Int
    let ladder_gate: Int
    let topless_ladder_gate: Int
    let dive_gate: Int
    let launch_gate: Int
    let hurtle: Int
}

public class Track: Mappable, Descriptable {

    public var id: ObjectId = ""
    public var title: String = ""
    public var leaderboardUrl: String = ""
    public var `type`: TrackType = .general
    public var `class`: TrackClass = .open

    public var isUTT: Bool = false
    public var isGQ: Bool = false
    public var isMega: Bool = false

    public var elements: TrackElements?

    // MARK: - Initialization

    fileprivate static let requiredProperties = ["id"]

    public required convenience init?(map: Map) {
        for requiredProperty in Self.requiredProperties {
            if map.JSON[requiredProperty] == nil { return nil }
        }

        self.init()
        self.mapping(map: map)
    }

    public func mapping(map: Map) {
        id <- map["id"]
        title <- map["title"]
        leaderboardUrl <- map["leaderboardUrl"]
        `type` <- (map["type"], EnumTransform<TrackType>())
        `class` <- (map["class"], EnumTransform<TrackClass>())

        isUTT = `type` == .utt
        isGQ = `type` == .gq
        isMega = `class` == .mega

        elements <- map["elements"]
    }
}
