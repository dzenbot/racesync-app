//
//  Aircraft.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-22.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class Aircraft: Mappable, Descriptable {

    public var id: ObjectId = ""
    public var scannableId: String = ""
    public var name: String = ""
    public var description: String?
    public var mainImageUrl: String?
    public var backgroundImageUrl: String?

    public var type: AircraftType?
    public var size: AircraftSize?
    public var battery: BatterySize?
    public var propSize: PropellerSize?
    public var videoTxType: VideoTxType = .´5800mhz´
    public var videoTxPower: VideoTxPower?
    public var videoTxChannels: VideoChannels = .raceband40
    public var videoRxChannels: VideoChannels?
    public var antenna: AntennaPolarization = .both

    // MARK: - Initialization

    fileprivate static let requiredProperties = ["id", "name"]

    public required convenience init?(map: Map) {
        for requiredProperty in Aircraft.requiredProperties {
            if map.JSON[requiredProperty] == nil { return nil }
        }

        self.init()
        self.mapping(map: map)
    }

    public func mapping(map: Map) {
        id <- map["id"]
        scannableId <- map["scannableId"]
        name <- map["name"]
        description <- map["description"]
        mainImageUrl <- map["mainImageFileName"]
        backgroundImageUrl <- map["backgroundFileName"]

        type <- (map["type"],EnumTransform<AircraftType>())
        size <- (map["size"],EnumTransform<AircraftSize>())
        battery <- (map["battery"],EnumTransform<BatterySize>())
        propSize <- (map["propellerSize"],EnumTransform<PropellerSize>())
        videoTxType <- (map["videoTransmitter"],EnumTransform<VideoTxType>())
        videoTxPower <- (map["videoTransmitterPower"],EnumTransform<VideoTxPower>())
        videoTxChannels <- (map["videoTransmitterChannels"],EnumTransform<VideoChannels>())
        videoRxChannels <- (map["videoReceiverChannels"],EnumTransform<VideoChannels>())
        antenna <- (map["antenna"],EnumTransform<AntennaPolarization>())
    }
}
