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
        let raceSpecs = AircraftRaceSpecs(with: race)

        self.name = "\(me?.userName ?? Random.string())-Drone-\(Random.int(length: 5000))"
        self.type = raceSpecs.types.first
        self.size = raceSpecs.sizes.first
        self.battery = raceSpecs.batteries.first
        self.propSize = raceSpecs.propSizes.first

        self.videoTxType = VideoTxType.´5800mhz´.rawValue
        self.videoTxPower = VideoTxPower.´25mw´.rawValue
        self.videoTxChannels = VideoChannels.raceband40.rawValue
        self.videoRxChannels = VideoChannels.raceband40.rawValue
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
        if videoTxPower != nil { parameters[ParameterKey.videoTransmitterPower] = videoTxPower }
        if videoTxChannels != nil { parameters[ParameterKey.videoTransmitterChannels] = videoTxChannels }
        if videoRxChannels != nil { parameters[ParameterKey.videoReceiverChannels] = videoRxChannels }
        if antenna != nil { parameters[ParameterKey.antenna] = antenna }

        return parameters
    }
}

public class AircraftRaceSpecs: Descriptable {

    public let types: [String]
    public let sizes: [String]
    public let batteries: [String]
    public let propSizes: [String]

    public init(with race: Race) {
        types = race.typeRestriction.components(separatedBy: ",").compactMap { $0 }.filter({ (value) -> Bool in
            return value.count > 0
        })

        sizes = race.sizeRestriction.components(separatedBy: ",").compactMap { $0 }.filter({ (value) -> Bool in
            return value.count > 0
        })

        batteries = race.batteryRestriction.components(separatedBy: ",").compactMap { $0 }.filter({ (value) -> Bool in
            return value.count > 0
        })

        propSizes = race.propSizeRestriction.components(separatedBy: ",").compactMap { $0 }.filter({ (value) -> Bool in
            return value.count > 0
        })
    }

    public func toParameters() -> Parameters {
        var parameters: Parameters = [:]

        if types.count > 0 { parameters[ParameterKey.type] = types }
        if sizes.count > 0 { parameters[ParameterKey.size] = sizes }
        if batteries.count > 0 { parameters[ParameterKey.battery] = batteries }
        if propSizes.count > 0 { parameters[ParameterKey.propSize] = propSizes }

        return parameters
    }
}
