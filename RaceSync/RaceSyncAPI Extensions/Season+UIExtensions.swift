//
//  Season+UIExtensions.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2023-01-16.
//  Copyright © 2023 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI

extension Season {

    // Official dates are enforced in this file
    // https://github.com/MultiGP/multigp-com/blob/09841623ae274fa8f62a3a4df1393cf1cf986b74/public_html/MultiGP/request/class.dataHelper.php#L94
    //
    // TODO: Pull these dates from the server instead of hardcoding them on the app
    static let GQStartDate: Date? = DateUtil.standardDateFormatter.date(from: "\(Date().thisYear())-04-01 00:00:01")
    static let GQEndDate: Date? = DateUtil.standardDateFormatter.date(from: "\(Date().thisYear())-07-18 23:59:59")

    /**
     Checks if the GQ date window is valid

     - parameter days: Optionally pass a day margin for expanding the window
     - returns True if the GQ date window is valid.
     */
    static func isGQWindowValid(_ daysMargin: Int = 0) -> Bool {
        guard let startDate = GQStartDate, let endDate = GQEndDate else { return false }

        let today = Date()

        if startDate.date(with: -daysMargin) > today && endDate.date(with: daysMargin) < today {
            return true
        }

        return false
    }
}
