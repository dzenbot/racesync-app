//
//  AircraftRaceData.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2022-12-28.
//  Copyright © 2022 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire

public class AircraftRaceData: Descriptable {

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

        if types.count > 0 { parameters[ParamKey.type] = types }
        if sizes.count > 0 { parameters[ParamKey.size] = sizes }
        if batteries.count > 0 { parameters[ParamKey.battery] = batteries }
        if propSizes.count > 0 { parameters[ParamKey.propellerSize] = propSizes }

        return parameters
    }

    public func displayText() -> String {

        var strings = [String]()

        if batteries.count > 0 {
            let enums = batteries.compactMap { BatterySize(rawValue: $0) }
            let numbers = enums.compactMap { $0.number }

            if let max = numbers.max() {
                strings += ["\(max)S"]
            }
        }

        if propSizes.count > 0 {
            let enums = propSizes.compactMap { PropellerSize(rawValue: $0) }
            let numbers = enums.compactMap { $0.number }

            if let max = numbers.max() {
                if max < 1 {
                    let mm = max*100
                    let cleanValue = mm.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", mm) : String(format: "%.1f", mm)
                    strings += ["\(cleanValue)mm"]
                } else {
                    let cleanValue = max.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", max) : String(format: "%.1f", max)
                    strings += ["\(cleanValue)\""]
                }
            }
        }

        if strings.count > 0 {
            return "Max \(strings.joined(separator: ", "))"
        } else if batteries.count == 0 && propSizes.count == 0 {
            return "Open Class"
        } else {
            return "N/A"
        }
    }
}
