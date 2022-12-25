//
//  IntegerTransform.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2022-12-24.
//  Copyright © 2022 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class IntegerTransform: TransformType {

    public typealias Object = Int64
    public typealias JSON = String

    init() {}
    public func transformFromJSON(_ value: Any?) -> Int64? {
        if let strValue = value as? String {
            return Int64(strValue)
        }
        return value as? Int64 ?? nil
    }

    public func transformToJSON(_ value: Int64?) -> String? {
        if let intValue = value {
            return "\(intValue)"
        }
        return nil
    }
}
