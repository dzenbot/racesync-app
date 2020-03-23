//
//  Race.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-18.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class Race: Mappable, Joinable, Descriptable {

    public var id: ObjectId = ""
    public var name: String = ""
    public var startDate: Date?
    public var mainImageFileName: String?
    public var status: RaceStatus = .open
    public var isJoined: Bool = false
    public var type: String = ""
    public var raceType: RaceType = .normal
    public var officialStatus: RaceOfficialStatus  = .normal

    public var url: String = ""
    public var urlName: String = ""
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

    public var typeRestriction: String = ""
    public var sizeRestriction: String = ""
    public var batteryRestriction: String = ""
    public var propSizeRestriction: String = ""

    public var races: [RaceLite]? = nil
    public var entries: [RaceEntry]? = nil

    // MARK: - Initialization

    fileprivate static let requiredProperties = ["id", "name", "chapterId", "ownerId"]

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
        id <- map["id"]
        name <- map["name"]
        startDate <- (map["startDate"], MapperUtil.dateTransform)
        mainImageFileName <- map["mainImageFileName"]
        isJoined <- map["isJoined"]
        status <- (map["status"],EnumTransform<RaceStatus>())
        type <- map["type"]
        raceType <- (map["raceType"],EnumTransform<RaceType>())
        officialStatus <- (map["officialStatus"],EnumTransform<RaceOfficialStatus>())
        url = "\(MGPWeb.getUrl(for: .raceView))=\(id)"
        urlName <- map["urlName"]
        description <- map["description"]
        content <- map["content"]
        itineraryContent <- map["itineraryContent"]
        raceEntryCount <- map["raceEntryCount"]
        participantCount <- map["participantCount"]

        address <- map["address"]
        city <- map["city"]
        state <- map["state"]
        country <- map["country"]
        zip <- map["zip"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]

        chapterId <- map["chapterId"]
        chapterName <- map["chapterName"]
        chapterImageFileName <- map["chapterImageFileName"]

        ownerId <- map["ownerId"]
        // TODO: Missing attribute when calling Race/SimpleView
        // https://github.com/MultiGP/racesync-api/issues/32
        ownerUserName <- map["ownerUserName"]

        childRaceCount <- map["childRaceCount"]
        parentRaceId <- map["parentRaceId"]
        courseId <- map["courseId"]
        seasonId <- map["seasonId"]

        typeRestriction <- map["typeRestriction"]
        sizeRestriction <- map["sizeRestriction"]
        batteryRestriction <- map["batteryRestriction"]
        propSizeRestriction <- map["propellerSizeRestriction"]

        races <- map["races"]
        entries <- map["entries"]
    }
}

public class RaceLite: Mappable, Descriptable {

    fileprivate static let requiredProperties = ["id", "name"]

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
