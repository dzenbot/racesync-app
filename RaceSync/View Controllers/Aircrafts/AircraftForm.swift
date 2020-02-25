//
//  AircraftForm.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-02-22.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI

enum AircraftRow: Int, EnumTitle, CaseIterable {
    case name, type, size, battery, propSize, videoTx, videoTxPower, videoTxChannels, videoRxChannels, antenna

    public var title: String {
        switch self {
        case .name:             return "Aircraft Name"
        case .type:             return "Type"
        case .size:             return "Size"
        case .battery:          return "Battery"
        case .propSize:         return "Propeller Size"
        case .videoTx:          return "Video Tx"
        case .videoTxPower:     return "Video Tx Power"
        case .videoTxChannels:  return "Video Tx Channels"
        case .videoRxChannels:  return "Video Rx Channels"
        case .antenna:          return "Antenna"
        }
    }
}

extension AircraftRow {

    var aircraftSpecValues: [String] {
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
        case .videoTxPower:
            return VideoTxPower.allCases.compactMap { $0.title }
        case .videoTxChannels:
            return VideoChannels.allCases.compactMap { $0.title }
        case .videoRxChannels:
            return VideoChannels.allCases.compactMap { $0.title }
        case .antenna:
            return AntennaPolarization.allCases.compactMap { $0.title }
        default:
            return [String]()
        }
    }

    var defaultAircraftSpecValue: String? {
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
        case .videoTxPower:
            return VideoTxPower.´25mw´.title
        case .videoTxChannels:
            return VideoChannels.raceband40.title
        case .videoRxChannels:
            return VideoChannels.raceband40.title
        case .antenna:
            return AntennaPolarization.both.title
        }
    }

    var isAircraftSpecRequired: Bool {
        switch self {
        case .name, .videoTx, .videoTxChannels, .antenna:
            return true
        default:
            return false
        }
    }

    func specValue(from aircraftViewModel: AircraftViewModel) -> String? {
        switch self {
        case .name:
            return aircraftViewModel.displayName
        case .type:
            return aircraftViewModel.aircraft?.type?.title
        case .size:
            return aircraftViewModel.aircraft?.size?.title
        case .battery:
            return aircraftViewModel.aircraft?.battery?.title
        case .propSize:
            return aircraftViewModel.aircraft?.propSize?.title
        case .videoTx:
            return aircraftViewModel.aircraft?.videoTxType.title
        case .videoTxPower:
            return aircraftViewModel.aircraft?.videoTxPower?.title
        case .videoTxChannels:
            return aircraftViewModel.aircraft?.videoTxChannels.title
        case .videoRxChannels:
            return aircraftViewModel.aircraft?.videoRxChannels?.title
        case .antenna:
            return aircraftViewModel.aircraft?.antenna.title
        }
    }

    func displayText(from aircraftViewModel: AircraftViewModel) -> String {
        switch self {
        case .name:
            return aircraftViewModel.displayName
        case .type:
            return aircraftViewModel.typeLabel
        case .size:
            return aircraftViewModel.sizeLabel
        case .battery:
            return aircraftViewModel.batteryLabel
        case .propSize:
            return aircraftViewModel.propSizeLabel
        case .videoTx:
            return aircraftViewModel.videoTxTypeLabel
        case .videoTxPower:
            return aircraftViewModel.videoTxPowerLabel
        case .videoTxChannels:
            return aircraftViewModel.videoTxChannelsLabel
        case .videoRxChannels:
            return aircraftViewModel.videoRxChannelsLabel
        case .antenna:
            return aircraftViewModel.antennaLabel
        }
    }

    func specValue(from aircraftSpecs: AircraftSpecs) -> String? {
        switch self {
        case .name:
            return aircraftSpecs.name
        case .type:
            return aircraftSpecs.type
        case .size:
            return aircraftSpecs.size
        case .battery:
            return aircraftSpecs.battery
        case .propSize:
            return aircraftSpecs.propSize
        case .videoTx:
            return aircraftSpecs.videoTxType
        case .videoTxPower:
            return aircraftSpecs.videoTxPower
        case .videoTxChannels:
            return aircraftSpecs.videoTxChannels
        case .videoRxChannels:
            return aircraftSpecs.videoRxChannels
        case .antenna:
            return aircraftSpecs.antenna
        }
    }

    func displayText(from aircraftSpecs: AircraftSpecs) -> String? {
        switch self {
        case .name:
            return aircraftSpecs.name
        case .type:
            if let type = aircraftSpecs.type {
                return AircraftType(rawValue: type)?.title
            }
            return nil
        case .size:
            if let type = aircraftSpecs.size {
                return AircraftSize(rawValue: type)?.title
            }
            return nil
        case .battery:
            if let type = aircraftSpecs.battery {
                return BatterySize(rawValue: type)?.title
            }
            return nil
        case .propSize:
            if let type = aircraftSpecs.propSize {
                return PropellerSize(rawValue: type)?.title
            }
            return nil
        case .videoTx:
            if let type = aircraftSpecs.videoTxType {
                return VideoTxType(rawValue: type)?.title
            }
            return nil
        case .videoTxPower:
            if let type = aircraftSpecs.videoTxPower {
                return VideoTxPower(rawValue: type)?.title
            }
            return nil
        case .videoTxChannels:
            if let type = aircraftSpecs.videoTxChannels {
                return VideoChannels(rawValue: type)?.title
            }
            return nil
        case .videoRxChannels:
            if let type = aircraftSpecs.videoRxChannels {
                return VideoChannels(rawValue: type)?.title
            }
            return nil
        case .antenna:
            if let type = aircraftSpecs.antenna {
                return AntennaPolarization(rawValue: type)?.title
            }
            return nil
        }
    }
}
