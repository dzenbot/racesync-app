//
//  ResultEntry.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2024-12-18.
//  Copyright © 2024 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class ResultEntry: Mappable, Descriptable {

    public var id: ObjectId = ""
    public var raceEntryId: ObjectId = ""
    public var pilotId: ObjectId = ""

    public var pilotUserName: String = ""
    public var pilotName: String = ""
    public var userName: String = ""
    public var displayName: String = ""
    public var firstName: String = ""
    public var lastName: String = ""
    public var profilePictureUrl: String?

    public var score: String? // Make number
    public var totalLaps: String? // Make number
    public var totalTime: String?
    public var fastest3Laps: String?
    public var fastest2Laps: String?
    public var fastestLap: String?

    public var roundName: String?

    fileprivate static let requiredProperties = [ParamKey.id, ParamKey.raceEntryId, ParamKey.pilotId]

    public required convenience init?(map: Map) {
        for requiredProperty in Self.requiredProperties {
            if map.JSON[requiredProperty] == nil { return nil }
        }

        self.init()
        self.mapping(map: map)
    }

    public func mapping(map: Map) {
        id <- map[ParamKey.id]
        raceEntryId <- map[ParamKey.raceEntryId]
        pilotId <- map[ParamKey.pilotId]

        pilotUserName <- (map[ParamKey.pilotUserName], MapperUtil.stringTransform)
        pilotName <- (map[ParamKey.pilotName], MapperUtil.stringTransform)
        userName <- (map[ParamKey.userName], MapperUtil.stringTransform)
        displayName <- (map[ParamKey.displayName], MapperUtil.stringTransform)
        firstName <- (map[ParamKey.firstName], MapperUtil.stringTransform)
        lastName <- (map[ParamKey.lastName], MapperUtil.stringTransform)
        profilePictureUrl <- map[ParamKey.profilePictureUrl]

        score <- map[ParamKey.score]
        totalLaps <- map[ParamKey.totalLaps]
        totalTime <- map[ParamKey.totalTime]
        fastest3Laps <- map[ParamKey.fastest3Laps]
        fastest2Laps <- map[ParamKey.fastest2Laps]
        fastestLap <- map[ParamKey.fastestLap]
    }
}

extension ResultEntry {

    static func resultEntries(from schedule: RaceSchedule?) -> [ResultEntry] {
        return schedule?.rounds
            .flatMap { $0.heats }
            .flatMap { $0.entries } ?? []
    }
}
