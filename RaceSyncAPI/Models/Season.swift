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
    public var urlName: String = ""
    public var description: String = ""
    public var chapterId: String = ""

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
        id <- map["id"]
        name <- map["name"]
        urlName <- map["urlName"]
        description <- map["description"]
        chapterId <- map["chapterId"]
    }
}
