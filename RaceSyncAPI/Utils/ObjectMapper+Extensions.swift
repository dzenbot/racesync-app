//
//  ObjectMapper+Extensions.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-11.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper

extension ImmutableMappable {

    static func from(JSON: [String : Any]) -> Self? {
        do {
            let mapped = try Self.init(JSON: JSON)
            return mapped
        } catch {
            return nil
        }
    }

}
