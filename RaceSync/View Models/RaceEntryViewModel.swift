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
        self.bandLabel = VideoChannels.bandTitle(for: raceEntry.band)
        self.channelLabel = Self.channelLabel(for: raceEntry)
        self.antennaLabel = AntennaPolarization.both.title
        self.shortChannelLabel = Self.shortChannelLabel(for: raceEntry)
        self.avatarUrl = raceEntry.profilePictureUrl
    }
}

extension RaceEntryViewModel {

    static func channelLabel(for raceEntry: RaceEntry) -> String {
        return "\(raceEntry.channel) (\(raceEntry.frequency))"
    }

    static func shortChannelLabel(for raceEntry: RaceEntry) -> String {
        if !raceEntry.band.isEmpty && !raceEntry.channel.isEmpty {
            return "\(raceEntry.band.capitalized)\(raceEntry.channel)"
        } else {
            return raceEntry.frequency
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
