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

    public func convert(_ value: CGFloat, from: APIUnitSystem, to: APIUnitSystem) -> CGFloat {
        return 0
    }

    public func convert(_ value: CGFloat, from: APIUnitSystem, to: APIUnitSystem) -> String {
        return ""
    }
}
