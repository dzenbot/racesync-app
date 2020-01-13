//
//  Air.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-12.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation
import Alamofire

public class AircraftSpecs: Descriptable {

    let name: String
    let videoTransmitter: Int
    let videoTransmitterChannels: Int
    let antenna: Int

    let type: Int?
    let size: Int?
    let batterySize: Int?
    let propellerSize: Int?

    public init(with race: Race) {

        let me = APIServices.shared.myUser
        self.name = "\(me?.userName ?? Random.string())-Drone-\(Random.int(length: 200))"
        self.videoTransmitter = VideoTxType.´5800mhz´.rawValue
        self.videoTransmitterChannels = VideoChannels.raceband40.rawValue
        self.antenna = AntennaPolarization.both.rawValue

        let raceSpecs = AircraftRaceSpecs(with: race)
        self.type = raceSpecs.types.first
        self.size = raceSpecs.sizes.first
        self.batterySize = raceSpecs.batterySizes.first
        self.propellerSize = raceSpecs.propellerSizes.first
    }

    func toParameters() -> Parameters {
        var parameters: Parameters = [:]

        parameters[ParameterKey.name] = name
        parameters[ParameterKey.videoTransmitter] = videoTransmitter
        parameters[ParameterKey.videoTransmitterChannels] = videoTransmitterChannels
        parameters[ParameterKey.antenna] = antenna

        parameters[ParameterKey.type] = type
        parameters[ParameterKey.size] = size
        if batterySize != nil { parameters[ParameterKey.battery] = batterySize }
        if propellerSize != nil { parameters[ParameterKey.propellerSize] = propellerSize }

        return parameters
    }
}

public class AircraftRaceSpecs: Descriptable {

    let types: [Int]
    let sizes: [Int]
//    let videoTransmitter: [Int]
//    let videoTransmitterPower: [Int]
//    let videoTransmitterChannels: [Int]
//    let videoReceiverChannels: [Int]
//    let antenna: [Int]
    let batterySizes: [Int]
    let propellerSizes: [Int]

    public init(with race: Race) {
        types = race.typeRestriction.components(separatedBy: ",").compactMap { Int($0) }
        sizes = race.sizeRestriction.components(separatedBy: ",").compactMap { Int($0) }
        batterySizes = race.batteryRestriction.components(separatedBy: ",").compactMap { Int($0) }
        propellerSizes = race.propellerSizeRestriction.components(separatedBy: ",").compactMap { Int($0) }
    }

    func toParameters() -> Parameters {
        var parameters: Parameters = [:]

        if types.count > 0 { parameters[ParameterKey.type] = types }
        if sizes.count > 0 { parameters[ParameterKey.size] = sizes }
        if batterySizes.count > 0 { parameters[ParameterKey.battery] = batterySizes }
        if propellerSizes.count > 0 { parameters[ParameterKey.propellerSize] = propellerSizes }

        return parameters
    }
}
