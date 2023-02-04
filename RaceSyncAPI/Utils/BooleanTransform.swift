//
//  BooleanTransform.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2023-01-22.
//  Copyright © 2023 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class BooleanTransform: TransformType {

    public typealias Object = Bool
    public typealias JSON = String

    init() {}
    public func transformFromJSON(_ value: Any?) -> Bool? {
        if let strValue = value as? String {
            return Bool(truncating: NSNumber(value: Int(strValue) ?? 0))
        }
        return value as? Bool ?? nil
    }

    public func transformToJSON(_ value: Bool?) -> String? {
        if let boolValue = value {
            return boolValue ? "1" : "0"
        }
        return nil
    }
}
