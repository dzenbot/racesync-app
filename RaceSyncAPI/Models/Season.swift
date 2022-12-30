//
//  Season.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-22.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class Season: Mappable, Descriptable {

    public var id: ObjectId = ""
    public var name: String = ""
    public var chapterId: ObjectId = ""
    public var description: String = ""

    // MARK: - Initialization

    fileprivate static let requiredProperties = [ParameterKey.id]

    public required convenience init?(map: Map) {
        for requiredProperty in Self.requiredProperties {
            if map.JSON[requiredProperty] == nil { return nil }
        }

        self.init()
        self.mapping(map: map)
    }

    public func mapping(map: Map) {
        id <- map[ParameterKey.id]
        name <- map[ParameterKey.name]
        chapterId <- map[ParameterKey.chapterId]
        description <- map["description"]
    }
}
