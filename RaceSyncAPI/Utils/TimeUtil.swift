//
//  TimeUtil.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2024-12-19.
//  Copyright © 2024 MultiGP Inc. All rights reserved.
//

import Foundation

public class TimeUtil {

    public static func lapTimeFormat(seconds timeString: String) -> String {
        guard let time = Double(timeString) else { return "" }

        // Round up the total seconds
        let totalSeconds = ceil(time * 1000) / 1000

        let minutes = Int(totalSeconds) / 60
        let seconds = Int(totalSeconds) % 60
        let milliseconds = Int((totalSeconds - floor(totalSeconds)) * 1000)

        if totalSeconds < 60 {
            // Format into "SS.mmm"
            return String(format: "%02d.%03d", seconds, milliseconds)
        } else {
            // Format into "MM:SS.mmm"
            return String(format: "%02d:%02d.%03d", minutes, seconds, milliseconds) // TODO: Add attributed string for the ms part?
        }
    }
}




