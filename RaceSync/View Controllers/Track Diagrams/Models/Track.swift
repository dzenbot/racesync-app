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

public enum SpecClass {
    case open, mega, micro, tiny
}

public class Track: Mappable, Descriptable {

    public var id: ObjectId = ""
    public var title: String = ""
    public var validationUrl: String = ""
    public var leaderboardId: ObjectId = ""
    public var `class`: SpecClass = .open

    public var flagCount: Int = 0
    public var gateCount: Int = 0

    public var isUTT: Bool = false
    public var isGQ: Bool = false
    public var isMega: Bool = false

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
        validationUrl <- map["validationUrl"]
        leaderboardId <- map["leaderboardId"]
        `class` <- map["class"]
        
        flagCount <- map["flagCount"]
        gateCount <- map["gateCount"]

        isUTT <- map["isUTT"]
        isGQ <- map["isGQ"]
        isMega = `class` == .mega
    }
}
