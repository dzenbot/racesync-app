//
//  Course.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2022-12-26.
//  Copyright © 2022 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class Course: Mappable, Descriptable {

    // MARK: - Initialization

    fileprivate static let requiredProperties = ["id"]

    public required convenience init?(map: Map) {
        for requiredProperty in Self.requiredProperties {
            if map.JSON[requiredProperty] == nil { return nil }
        }

        self.init()
        self.mapping(map: map)
    }

    public func mapping(map: Map) {

    }

}
