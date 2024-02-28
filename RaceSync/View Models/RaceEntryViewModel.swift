//
//  RaceEntryViewModel.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-13.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import RaceSyncAPI
import UIKit

class RaceEntryViewModel: Descriptable {

    let raceEntry: RaceEntry

    let bandLabel: String
    let channelLabel: String
    let antennaLabel: String
    let shortChannelLabel: String
    let avatarUrl: String?

    init(with raceEntry: RaceEntry) {
        self.raceEntry = raceEntry
        self.bandLabel = Self.bandLabel(for: raceEntry)
        self.channelLabel = Self.channelLabel(for: raceEntry)
        self.antennaLabel = AntennaPolarization.both.title
        self.shortChannelLabel = Self.shortChannelLabel(for: raceEntry)
        self.avatarUrl = raceEntry.profilePictureUrl
    }
}

extension RaceEntryViewModel {

    static func bandLabel(for raceEntry: RaceEntry) -> String {
        if raceEntry.videoTxType == .DJI || raceEntry.videoTxType == .HDZero {
            return raceEntry.videoTxType.title
        } else {
            return VideoChannels.bandTitle(for: raceEntry.band)
        }
    }

    static func channelLabel(for raceEntry: RaceEntry) -> String {
        return "\(raceEntry.channel) (\(raceEntry.frequency))"
    }

    static func shortChannelLabel(for raceEntry: RaceEntry) -> String {
        guard !raceEntry.channel.isEmpty else { return raceEntry.frequency }

        if raceEntry.videoTxType == .DJI {
            return "DJI\(raceEntry.channel)"
        } else if raceEntry.videoTxType == .HDZero {
            return "HDZ\(raceEntry.channel)"
        } else {
            return "\(raceEntry.band.capitalized)\(raceEntry.channel)"
        }
    }

    static func backgroundColor(for raceEntry: RaceEntry) -> UIColor {
        if !raceEntry.band.isEmpty && !raceEntry.channel.isEmpty {
            let seed = "\(VideoChannels.bandTitle(for: raceEntry.band)) \(raceEntry.channel)"
            return UIColor.randomColor(seed: seed)
        } else {
            return Color.gray200
        }
    }
}
