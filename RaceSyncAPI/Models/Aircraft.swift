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
    public var name: String = ""
    public var scannableId: String = ""
    public var description: String?
    public var mainImageUrl: String?
    public var backgroundImageUrl: String?

    public var type: AircraftType?
    public var size: AircraftSize?
    public var battery: BatterySize?
    public var propSize: PropellerSize?
    public var videoTxType: VideoTxType = .´5800mhz´ // Analog 5.8GHz default
    public var videoTxPower: VideoTxPower?
    public var videoTxChannels: VideoChannels = .raceband40 // Raceband default
    public var videoRxChannels: VideoChannels?
    public var antenna: AntennaPolarization = .both

    public static let nameMinLength: Int = 3
    public static let nameMaxLength: Int = 20

    // MARK: - Initialization

    fileprivate static let requiredProperties = [ParameterKey.id, ParameterKey.name]

    public required convenience init?(map: Map) {
        for requiredProperty in Self.requiredProperties {
            if map.JSON[requiredProperty] == nil { return nil }
        }

        self.init()
        self.mapping(map: map)
    }

    public func mapping(map: Map) {
        id <- map[ParameterKey.id]
        name <- map[ParameterKey.name]
        scannableId <- map["scannableId"]
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
