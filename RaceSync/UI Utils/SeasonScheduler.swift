//
//  SeasonScheduler.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2022-01-24.
//  Copyright © 2022 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI

public class SeasonConstants {
    public static let seasonStart: String = "\(Date().thisYear())-04-01 12:01 AM"
    public static let seasonEnd: String = "\(Date().thisYear())-07-18 11:59 PM"
}

class SeasonScheduler {

    static func isActive() -> Bool {
        guard let seasonStartDate = DateUtil.standardDateFormatter.date(from: SeasonConstants.seasonStart) else { return false }
        guard let seasonEndDate = DateUtil.standardDateFormatter.date(from: SeasonConstants.seasonEnd) else { return false }

        return seasonStartDate.isPassed && !seasonEndDate.isPassed
    }
}
