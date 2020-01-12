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

    let type: Int
    let size: Int
    let batterySize: Int
    let propellerSize: Int

    public init?(with race: Race) {

        let raceSpecs = AircraftRaceSpecs(with: race)

        guard let type = raceSpecs.types.first else { return nil }
        guard let size = raceSpecs.sizes.first else { return nil }
        guard let batterySize = raceSpecs.batterySizes.first else { return nil }
        guard let propellerSize = raceSpecs.propellerSizes.first else { return nil }

        self.type = type
        self.size = size
        self.batterySize = batterySize
        self.propellerSize = propellerSize
    }

    func toParameters() -> Parameters {
        var parameters: Parameters = [:]

        parameters[ParameterKey.type] = type
        parameters[ParameterKey.size] = size
        parameters[ParameterKey.battery] = batterySize
        parameters[ParameterKey.propellerSize] = propellerSize

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
