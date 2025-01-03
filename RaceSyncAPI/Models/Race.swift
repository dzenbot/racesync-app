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
    public var endDate: Date?
    public var mainImageFileName: String?
    public var statusString: String = ""
    public var status: RaceStatus = .open
    public var isJoined: Bool = false
    public var type: EventType = .public
    public var scoringFormat: ScoringFormat = .aggregateLap
    public var raceClass: RaceClass = .open
    public var raceClassString: String = "Open"
    public var raceType: RaceType = .normal
    public var officialStatus: RaceOfficialStatus = .normal
    public var scoringDisabled: Bool = false
    public var captureTimeEnabled: Bool = true
    public var cycleCount: Int32 = 0
    public var disableSlotAutoPopulation: QualifyingType = .controlled
    public var maxZippyqDepth: Int32 = 0
    public var zippyqIterator: Bool = false
    public var maxBatteriesForQualifying: Int32 = 0

    public var url: String = ""
    public var urlName: String = ""
    public var liveTimeUrl: String?
    public var description: String = ""
    public var content: String = ""
    public var itinerary: String = ""
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
    public var seasonId: ObjectId?
    public var seasonName: String = ""
    public var courseId: ObjectId?
    public var courseName: String = ""

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
        endDate <- (map[ParamKey.endDate], MapperUtil.dateTransform)
        mainImageFileName <- map[ParamKey.mainImageFileName]
        isJoined <- map[ParamKey.isJoined]
        statusString <- map[ParamKey.status] // The API returns a status string, instead of enum

        if statusString == RaceStatus.open.title {
            status = RaceStatus.open
        } else {
            status = RaceStatus.closed
        }

        type <- (map[ParamKey.type], EnumTransform<EventType>())
        scoringFormat <- (map[ParamKey.scoringFormat], EnumTransform<ScoringFormat>())
        raceClass <- (map[ParamKey.raceClass], EnumTransform<RaceClass>())
        raceClassString <- map[ParamKey.raceClassString]
        raceType <- (map[ParamKey.raceType], EnumTransform<RaceType>())
        officialStatus <- (map[ParamKey.officialStatus], EnumTransform<RaceOfficialStatus>())
        captureTimeEnabled <- (map[ParamKey.captureTimeEnabled], BooleanTransform()) // returned as String from API
        scoringDisabled <- (map[ParamKey.scoringDisabled], BooleanTransform()) // returned as String from API
        cycleCount <- (map[ParamKey.cycleCount], IntegerTransform())
        disableSlotAutoPopulation <- (map[ParamKey.disableSlotAutoPopulation], EnumTransform<QualifyingType>())
        maxZippyqDepth <- (map[ParamKey.maxZippyqDepth], IntegerTransform())
        zippyqIterator <- map[ParamKey.zippyqIterator]
        maxBatteriesForQualifying <- (map[ParamKey.maxBatteriesForQualifying], IntegerTransform())

        url = MGPWeb.getUrl(for: .raceView, value: id)
        urlName <- map[ParamKey.urlName]
        liveTimeUrl <- map[ParamKey.liveTimeUrl]
        description <- map[ParamKey.description]
        content <- map[ParamKey.content]
        itinerary <- map[ParamKey.itineraryContent]
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
        seasonId <- map[ParamKey.seasonId]
        seasonName <- map[ParamKey.seasonName]
        courseId <- map[ParamKey.courseId]
        courseName <- map[ParamKey.courseName]

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
        id <- map[ParamKey.id]
        name <- map[ParamKey.name]
    }
}
