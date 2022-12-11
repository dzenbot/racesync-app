//
//  APIUnitSystem.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2020-02-28.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation
import CoreGraphics

public enum APIMeasurementSystem: Int, EnumTitle {
    case imperial, metric

    public var title: String {
        switch self {
        case .imperial:     return "Imperial"
        case .metric:       return "Metric"
        }
    }
}

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
        case .miles:        return ["100", "200", "500", "2000", "3000"]
        case .kilometers:   return ["150", "300", "750", "3000", "4500"]
        }
    }

    public var defaultValue: String {
        switch self {
        case .miles:        return "200"
        case .kilometers:   return "300"
        }
    }

    public static func convert(_ value: Double, to: APIUnitSystem) -> Double {
        if to == .miles {
            return value * 0.621371
        } else if to == .kilometers {
            return value * 1.60934
        }
        return value
    }

    public static func convert(_ string: String, to: APIUnitSystem) -> String {
        guard let number = Double(string) else { return string }

        let value = convert(number, to: to)
        return NumberUtil.string(for: value)
    }
}
