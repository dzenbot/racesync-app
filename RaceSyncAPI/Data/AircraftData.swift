//
//  AircraftData.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-12.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire

public class AircraftData: Descriptable {

    public var name: String?
    public var type: String?
    public var size: String?
    public var battery: String?
    public var propSize: String?

    public var videoTxType: String?
    public var videoTxPower: String?
    public var videoTxChannels: String?
    public var videoRxChannels: String?
    public var antenna: String?

    public init(with race: Race) {
        let me = APIServices.shared.myUser
        let raceData = AircraftRaceData(with: race)

        self.name = "\(me?.userName ?? Random.string())-Drone-\(Random.int(length: 5000))"
        self.type = raceData.types.first
        self.size = raceData.sizes.first
        self.battery = raceData.batteries.first
        self.propSize = raceData.propSizes.first

        self.videoTxType = VideoTxType.´5800mhz´.rawValue
        self.antenna = AntennaPolarization.both.rawValue
    }

    public init() { }

    func toParameters() -> Parameters {
        var parameters: Parameters = [:]

        if name != nil { parameters[ParameterKey.name] = name }
        if type != nil { parameters[ParameterKey.type] = type }
        if size != nil { parameters[ParameterKey.size] = size }
        if battery != nil { parameters[ParameterKey.battery] = battery }
        if propSize != nil { parameters[ParameterKey.propSize] = propSize }

        if videoTxType != nil { parameters[ParameterKey.videoTransmitter] = videoTxType }
        if antenna != nil { parameters[ParameterKey.antenna] = antenna }

        return parameters
    }
}
