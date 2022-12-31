//
//  Race.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-18.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire

public class Race: Mappable, Joinable, Descriptable {

    public var id: ObjectId = ""
    public var name: String = ""
    public var startDate: Date?
    public var mainImageFileName: String?
    public var status: RaceStatus = .opened
    public var isJoined: Bool = false
    public var type: String = ""
    public var raceType: RaceType = .normal
    public var officialStatus: RaceOfficialStatus  = .normal
    public var scoringDisabled: Bool = false
    public var captureTimeEnabled: Bool = true
    public var cycleCount: Int64 = 0
    public var maxZippyqDepth: Int64 = 0
    public var zippyqIterator: Bool = false
    public var maxBatteriesForQualifying: Int64 = 0

    public var url: String = ""
    public var urlName: String = ""
    public var liveTimeUrl: String?
    public var description: String = ""
    public var content: String = ""
    public var itineraryContent: String = ""
    public var raceEntryCount: String = ""
    public var participantCount: String = ""

    public var address: String?
    public var city: String?
    public var state: String?
    public var country: String?
    public var zip: String?
    public var latitude: String = ""
    public var longitude: String = ""

    public var chapterId: ObjectId = ""
    public var chapterName: String = ""
    public var chapterImageFileName: String?

    public var ownerId: ObjectId = ""
    public var ownerUserName: String = ""

    public var childRaceCount: String?
    public var parentRaceId: ObjectId?
    public var courseId: ObjectId?
    public var seasonId: ObjectId?
    public var seasonName: String = ""

    public var typeRestriction: String = ""
    public var sizeRestriction: String = ""
    public var batteryRestriction: String = ""
    public var propSizeRestriction: String = ""

    public var races: [RaceLite]? = nil
    public var entries: [RaceEntry]? = nil

    public static let nameMinLength: Int = 3
    public static let nameMaxLength: Int = 50

    // MARK: - Initialization

    fileprivate static let requiredProperties = [ParamKey.id, ParamKey.name, ParamKey.chapterId, ParamKey.ownerId]

    public required convenience init?(map: Map) {
        for requiredProperty in Self.requiredProperties {
            if map.JSON[requiredProperty] == nil {
                return nil
            }
        }

        self.init()
        self.mapping(map: map)
    }

    public func mapping(map: Map) {
        id <- map[ParamKey.id]
        name <- map[ParamKey.name]
        startDate <- (map[ParamKey.startDate], MapperUtil.dateTransform)
        mainImageFileName <- map[ParamKey.mainImageFileName]
        isJoined <- map[ParamKey.isJoined]
        status <- (map[ParamKey.status], EnumTransform<RaceStatus>())
        type <- map[ParamKey.type]
        raceType <- (map[ParamKey.raceType], EnumTransform<RaceType>())
        officialStatus <- (map[ParamKey.officialStatus], EnumTransform<RaceOfficialStatus>())
        captureTimeEnabled <- map[ParamKey.captureTimeEnabled]
        scoringDisabled <- map[ParamKey.scoringDisabled]
        cycleCount <- (map[ParamKey.cycleCount], IntegerTransform())
        maxZippyqDepth <- (map[ParamKey.maxZippyqDepth], IntegerTransform())
        zippyqIterator <- map[ParamKey.zippyqIterator]
        maxBatteriesForQualifying <- (map[ParamKey.maxBatteriesForQualifying], IntegerTransform())

        url = MGPWeb.getUrl(for: .raceView, value: id)
        urlName <- map[ParamKey.urlName]
        liveTimeUrl <- map[ParamKey.liveTimeUrl]
        description <- map[ParamKey.description]
        content <- map[ParamKey.content]
        itineraryContent <- map[ParamKey.itineraryContent]
        raceEntryCount <- map[ParamKey.raceEntryCount]
        participantCount <- map[ParamKey.participantCount]

        address <- map[ParamKey.address]
        city <- map[ParamKey.city]
        state <- map[ParamKey.state]
        country <- map[ParamKey.country]
        zip <- map[ParamKey.zip]
        latitude <- map[ParamKey.latitude]
        longitude <- map[ParamKey.longitude]

        chapterId <- map[ParamKey.chapterId]
        chapterName <- map[ParamKey.chapterName]
        chapterImageFileName <- map[ParamKey.chapterImageFileName]

        ownerId <- map[ParamKey.ownerId]
        ownerUserName <- map[ParamKey.ownerUserName]

        childRaceCount <- map[ParamKey.childRaceCount]
        parentRaceId <- map[ParamKey.parentRaceId]
        courseId <- map[ParamKey.courseId]
        seasonId <- map[ParamKey.seasonId]
        seasonName <- map[ParamKey.seasonName]

        typeRestriction <- map[ParamKey.typeRestriction]
        sizeRestriction <- map[ParamKey.sizeRestriction]
        batteryRestriction <- map[ParamKey.batteryRestriction]
        propSizeRestriction <- map[ParamKey.propellerSizeRestriction]

        races <- map[ParamKey.races]
        entries <- map[ParamKey.entries]
    }
}

public class RaceLite: Mappable, Descriptable {

    fileprivate static let requiredProperties = [ParamKey.id, ParamKey.name]

    public var id: String = ""
    public var name: String = ""

    // MARK: - Initialization

    public required convenience init?(map: Map) {
        for requiredProperty in RaceLite.requiredProperties {
            if map.JSON[requiredProperty] == nil { return nil }
        }

        self.init()
        self.mapping(map: map)
    }

    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}
