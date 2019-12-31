//
//  Race.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-18.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class Race: Mappable, Descriptable {

    public var id: ObjectId = ""
    public var name: String = ""
    public var startDate: Date?
    public var mainImageFileName: String?
    public var status: String = ""
    public var officialStatus: String = ""
    public var isJoined: Bool = false
    public var type: String = ""
    public var raceType: RaceType = .normal
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

    public var races: [RaceLite]? = nil
    public var entries: [RaceEntry]? = nil

    // MARK: - Initialization

    // Some APIs does not always provide the id attribute. Skipping for now.
    // https://github.com/mainedrones/RaceSync/pull/37
    fileprivate static let requiredProperties = [/*"id",*/ "name", "chapterId", "ownerId"]

    public required convenience init?(map: Map) {
        for requiredProperty in Race.requiredProperties {
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
        status <- map["status"]
        officialStatus <- map["officialStatus"]
        type <- map["type"]
        raceType <- map["raceType"]
        url = "https://www.multigp.com/races/view/?race=\(id)/"
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
        ownerUserName <- map["ownerUserName"]

        childRaceCount <- map["childRaceCount"]
        parentRaceId <- map["parentRaceId"]
        courseId <- map["courseId"]
        seasonId <- map["seasonId"]

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
