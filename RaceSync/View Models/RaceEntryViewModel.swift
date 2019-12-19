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
        self.bandLabel = RaceEntryViewModel.bandLabel(for: raceEntry)
        self.channelLabel = RaceEntryViewModel.channelLabel(for: raceEntry)
        self.antennaLabel = AntennaPolarization.both.rawValue
        self.shortChannelLabel = RaceEntryViewModel.shortChannelLabel(for: raceEntry)
        self.avatarUrl = raceEntry.profilePictureUrl
    }
}

extension RaceEntryViewModel {

    static func bandLabel(for raceEntry: RaceEntry) -> String {
        if raceEntry.band == "A" { return "Boscam A" }
        if raceEntry.band == "B" { return "Boscam B" }
        if raceEntry.band == "E" { return "Boscam E" }
        if raceEntry.band == "F" { return "IRC / FS" }
        if raceEntry.band == "R" { return "Race Band" }
        return ""
    }

    static func channelLabel(for raceEntry: RaceEntry) -> String {
        return "\(raceEntry.channel) (\(raceEntry.frequency))"
    }

    static func shortChannelLabel(for raceEntry: RaceEntry) -> String {
        return "\(raceEntry.band.capitalized)\(raceEntry.channel)"
    }

    static func backgroundColor(for raceEntry: RaceEntry) -> UIColor {
        let channel = "\(bandLabel(for: raceEntry)) \(raceEntry.channel)"
        return UIColor.randomColor(seed: channel)
    }
}
