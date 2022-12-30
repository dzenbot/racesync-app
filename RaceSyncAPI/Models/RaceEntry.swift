//
//  RaceEntry.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-11.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class RaceEntry: Mappable, Descriptable {

    public var id: ObjectId = ""
    public var pilotId: ObjectId = ""
    public var pilotUserName: String = ""
    public var pilotName: String = ""
    public var userName: String = ""
    public var displayName: String = ""
    public var firstName: String = ""
    public var lastName: String = ""
    public var scannableId: ObjectId?
    public var score: String?
    public var profilePictureUrl: String?

    public var frequency: String = ""
    public var group: String = ""
    public var groupSlot: String = ""
    public var band: String = ""
    public var channel: String = ""
    public var videoTxType: VideoTxType = .´5800mhz´ // Analog 5.8GHz default

    public var aircraftId: String = ""
    public var aircraftName: String = ""

    // MARK: - Initialization

    fileprivate static let requiredProperties = [ParamKey.id, ParamKey.pilotId, ParamKey.aircraftId]

    public required convenience init?(map: Map) {
        for requiredProperty in Self.requiredProperties {
            if map.JSON[requiredProperty] == nil { return nil }
        }

        self.init()
        self.mapping(map: map)
    }

    public func mapping(map: Map) {
        id <- map[ParamKey.id]
        pilotId <- map[ParamKey.pilotId]
        pilotUserName <- map["pilotUserName"]
        pilotName <- map["pilotName"]
        userName <- map["userName"]
        displayName <- map["displayName"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        scannableId <- map["scannableId"]
        score <- map["score"]
        profilePictureUrl <- map["profilePictureUrl"]

        frequency <- map["frequency"]
        group <- map["group"]
        groupSlot <- map["groupSlot"]
        band <- map["band"]
        channel <- map["channel"]
        videoTxType <- (map["videoTransmitter"],EnumTransform<VideoTxType>())

        aircraftId <- map[ParamKey.aircraftId]
        aircraftName <- map["aircraftName"]
    }
}
