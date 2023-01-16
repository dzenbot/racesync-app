//
//  Parameters+Extensions.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2023-01-15.
//  Copyright © 2023 MultiGP Inc. All rights reserved.
//

import Foundation

public typealias Params = [String: AnyHashable]

public extension Params {

    func diff(with p2: Params) -> Params {
        return Params.diff(between: self, and: p2)
    }

    // Returns a new dict with only the difference between the new and the old dict, giving priority to the newer one.
    // TODO: Make this way more dynamic, scalable. Perhaps as a protocol and default protocol implementation?
    // TODO: Define different priority levels (diff combined, exclusive or inclusive of older values)
    // TODO: Test with more value types?
    static func diff(between p1: Params, and p2: Params) -> Params {

        var result: Params = [:]

        p2.keys.forEach { key in
            if let s1 = p1[key] as? String {
                if let s2 = p2[key] as? String, s1 != s2 { result[key] = s2 }
            }
            else if let i1 = p1[key] as? Int {
                if let i2 = p2[key] as? Int, i1 != i2 { result[key] = i2 }
            }
            else if let b1 = p1[key] as? Bool {
                if let b2 = p2[key] as? Bool, b1 != b2 { result[key] = b2 }
            }
            else {
                result[key] = p2[key]
            }
        }

        return result
    }
}
