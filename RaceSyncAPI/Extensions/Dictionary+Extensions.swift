//
//  Dictionary+Extensions.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-11.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation

public extension Dictionary {

    static func +=(lhs: inout [Key: Value], rhs: [Key: Value]) {
        rhs.forEach({ lhs[$0] = $1})
    }
}
