//
//  AircraftViewModel.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-10.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI
import CoreLocation

class AircraftViewModel: Descriptable {

    var aircraft: Aircraft?

    let aircraftId: ObjectId
    let displayName: String
    let imageUrl: String?
    let isGeneric: Bool

    let typeLabel: String
    let sizeLabel: String
    let batteryLabel: String
    let propSizeLabel: String
    let videoTxTypeLabel: String
    let videoTxPowerLabel: String
    let videoRxChannelsLabel: String
    let videoTxChannelsLabel: String
    let antennaLabel: String

    init(with aircraft: Aircraft) {
        self.aircraft = aircraft
        self.aircraftId = aircraft.id
        self.displayName = aircraft.name
        self.imageUrl = aircraft.mainImageUrl
        self.isGeneric = false

        self.typeLabel = Self.typeLabelString(for: aircraft)
        self.sizeLabel = Self.sizeLabelString(for: aircraft)
        self.batteryLabel = Self.batteryLabelString(for: aircraft)
        self.propSizeLabel = Self.propSizeLabelString(for: aircraft)
        self.videoTxTypeLabel = aircraft.videoTxType.title
        self.videoTxPowerLabel = Self.videoTxPowerLabelString(for: aircraft)
        self.videoRxChannelsLabel = Self.videoRxLabelString(for: aircraft)
        self.videoTxChannelsLabel = aircraft.videoTxChannels.title
        self.antennaLabel = aircraft.antenna.title
    }

    init(genericWith title: String) {
        self.aircraft = nil
        self.aircraftId = ""
        self.displayName = title
        self.imageUrl = nil
        self.isGeneric = true

        self.typeLabel = ""
        self.sizeLabel = ""
        self.batteryLabel = ""
        self.propSizeLabel = ""
        self.videoTxTypeLabel = ""
        self.videoTxPowerLabel = ""
        self.videoRxChannelsLabel = ""
        self.videoTxChannelsLabel = ""
        self.antennaLabel = ""
    }

    static func viewModels(with objects:[Aircraft]) -> [AircraftViewModel] {
        var viewModels = [AircraftViewModel]()
        for object in objects {
            viewModels.append(AircraftViewModel(with: object))
        }
        return viewModels
    }
}

extension AircraftViewModel {

    static let Unavailable = "Not Set"

    static func typeLabelString(for aircraft: Aircraft) -> String {
        guard let type = aircraft.type else { return Unavailable }
        return type.title
    }

    static func sizeLabelString(for aircraft: Aircraft) -> String {
        guard let size = aircraft.size else { return Unavailable }
        return size.title
    }

    static func batteryLabelString(for aircraft: Aircraft) -> String {
        guard let battery = aircraft.battery else { return Unavailable }
        return battery.title
    }

    static func propSizeLabelString(for aircraft: Aircraft) -> String {
        guard let propSize = aircraft.propSize else { return Unavailable }
        return propSize.title
    }

    static func videoTxPowerLabelString(for aircraft: Aircraft) -> String {
        guard let videoTxPower = aircraft.videoTxPower else { return Unavailable }
        return videoTxPower.title
    }

    static func videoRxLabelString(for aircraft: Aircraft) -> String {
        guard let videoRxChannels = aircraft.videoRxChannels else { return Unavailable }
        return videoRxChannels.title
    }
}
