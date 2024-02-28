//
//  NumberUtil.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-19.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

public class NumberUtil {

    public static func string(for float: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 1
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        return formatter.string(from: NSNumber(value: float)) ?? "\(float)"
    }
}
