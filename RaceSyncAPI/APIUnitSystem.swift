//
//  APIUnitSystem.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2020-02-28.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation
import CoreGraphics

public enum APIUnitSystem: Int, EnumTitle {
    case miles, kilometers

    public var title: String {
        switch self {
        case .miles:        return "Miles"
        case .kilometers:   return "Kilometers"
        }
    }

    public var symbol: String {
        switch self {
        case .miles:        return "mi"
        case .kilometers:   return "km"
        }
    }

    public var supportedValues: [String] {
        switch self {
        case .miles:        return ["100", "200", "500", "2000"]
        case .kilometers:   return ["150", "300", "750", "3000"]
        }
    }

    public var defaultValue: String {
        switch self {
        case .miles:        return "200"
        case .kilometers:   return "300"
        }
    }

    public static func convert(_ string: String, to: APIUnitSystem) -> String {
        guard let number = Double(string) else { return string }

        if to == .miles {
            let value = number * 0.621371
            return NumberUtil.string(for: value)
        } else if to == .kilometers {
            let value = number * 1.60934
            return NumberUtil.string(for: value)
        }

        return string
    }
}
