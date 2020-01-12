//
//  Aircraft.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-22.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class Aircraft: Mappable, Descriptable {

    public var id: ObjectId = ""
    public var scannableId: String = ""
    public var name: String = ""
    public var description: String?
    public var mainImageUrl: String?
    public var backgroundImageUrl: String?

    // MARK: - Initialization

    fileprivate static let requiredProperties = ["id"]

    public required convenience init?(map: Map) {
        for requiredProperty in Aircraft.requiredProperties {
            if map.JSON[requiredProperty] == nil { return nil }
        }

        self.init()
        self.mapping(map: map)
    }

    public func mapping(map: Map) {
        id <- map["id"]
        scannableId <- map["scannableId"]
        name <- map["name"]
        description <- map["description"]
        mainImageUrl <- map["mainImageFileName"]
        backgroundImageUrl <- map["backgroundFileName"]
    }
}
