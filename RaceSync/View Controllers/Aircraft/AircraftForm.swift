//
//  AircraftForm.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-02-22.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI

enum AircraftFormRow: Int, EnumTitle, CaseIterable {
    case name, type, size, battery, propSize, videoTx, antenna

    public var title: String {
        switch self {
        case .name:             return "Aircraft Name"
        case .type:             return "Type"
        case .size:             return "Size"
        case .battery:          return "Battery"
        case .propSize:         return "Propeller Size"
        case .videoTx:          return "Video Tx"
        case .antenna:          return "Antenna"
        }
    }
}

extension AircraftFormRow {

    var values: [String] {
        switch self {
        case .type:
            return AircraftType.allCases.compactMap { $0.title }
        case .size:
            return AircraftSize.allCases.compactMap { $0.title }
        case .battery:
            return BatterySize.allCases.compactMap { $0.title }
        case .propSize:
            return PropellerSize.allCases.compactMap { $0.title }
        case .videoTx:
            return VideoTxType.allCases.compactMap { $0.title }
        case .antenna:
            return AntennaPolarization.allCases.compactMap { $0.title }
        default:
            return [String]()
        }
    }
    
    var defaultValue: String? {
        switch self {
        case .name:
            return nil
        case .type:
            return AircraftType.quad.title
        case .size:
            return AircraftSize.from250.title
        case .battery:
            return BatterySize.´4s´.title
        case .propSize:
            return PropellerSize.´5in´.title
        case .videoTx:
            return VideoTxType.´5800mhz´.title
        case .antenna:
            return AntennaPolarization.both.title
        }
    }

    var isRowRequired: Bool {
        switch self {
        case .name, .videoTx, .antenna:
            return true
        default:
            return false
        }
    }

    func value(from viewModel: AircraftViewModel) -> String? {
        switch self {
        case .name:
            return viewModel.displayName
        case .type:
            return viewModel.aircraft?.type?.title
        case .size:
            return viewModel.aircraft?.size?.title
        case .battery:
            return viewModel.aircraft?.battery?.title
        case .propSize:
            return viewModel.aircraft?.propSize?.title
        case .videoTx:
            return viewModel.aircraft?.videoTxType.title
        case .antenna:
            return viewModel.aircraft?.antenna.title
        }
    }

    func displayText(from viewModel: AircraftViewModel) -> String {
        switch self {
        case .name:
            return viewModel.displayName
        case .type:
            return viewModel.typeLabel
        case .size:
            return viewModel.sizeLabel
        case .battery:
            return viewModel.batteryLabel
        case .propSize:
            return viewModel.propSizeLabel
        case .videoTx:
            return viewModel.videoTxTypeLabel
        case .antenna:
            return viewModel.antennaLabel
        }
    }

    func value(from data: AircraftData) -> String? {
        switch self {
        case .name:
            return data.name
        case .type:
            return data.type
        case .size:
            return data.size
        case .battery:
            return data.battery
        case .propSize:
            return data.propSize
        case .videoTx:
            return data.videoTxType
        case .antenna:
            return data.antenna
        }
    }

    func displayText(from data: AircraftData) -> String? {
        switch self {
        case .name:
            return data.name
        case .type:
            if let type = data.type {
                return AircraftType(rawValue: type)?.title
            }
            return nil
        case .size:
            if let type = data.size {
                return AircraftSize(rawValue: type)?.title
            }
            return nil
        case .battery:
            if let type = data.battery {
                return BatterySize(rawValue: type)?.title
            }
            return nil
        case .propSize:
            if let type = data.propSize {
                return PropellerSize(rawValue: type)?.title
            }
            return nil
        case .videoTx:
            if let type = data.videoTxType {
                return VideoTxType(rawValue: type)?.title
            }
            return nil
        case .antenna:
            if let type = data.antenna {
                return AntennaPolarization(rawValue: type)?.title
            }
            return nil
        }
    }

    func aircraftRaceSpecValues(for data: AircraftRaceData) -> [String]? {
        switch self {
        case .type:
            if data.types.count > 0 {
                let enums = data.types.compactMap { AircraftType(rawValue: $0) }
                return enums.compactMap { $0.title }
            }
        case .size:
            if data.sizes.count > 0 {
                let enums = data.sizes.compactMap { AircraftSize(rawValue: $0) }
                return enums.compactMap { $0.title }
            }
        case .battery:
            if data.batteries.count > 0 {
                let enums = data.batteries.compactMap { BatterySize(rawValue: $0) }
                return enums.compactMap { $0.title }
            }
        case .propSize:
            if data.propSizes.count > 0 {
                let enums = data.propSizes.compactMap { PropellerSize(rawValue: $0) }
                return enums.compactMap { $0.title }
            }
        default:
            return nil
        }

        return nil
    }
}
