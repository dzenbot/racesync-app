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

    public var id: ObjectId = ""
    public var name: String = ""
    public var parentCourseId: ObjectId = ""
    public var description: String = ""
    public var type: String = ""

    public var mainImageUrl: String? //mainImageFileName
    public var backgroundUrl: String? //backgroundFileName

    public var address: String?
    public var city: String?
    public var state: String?
    public var zip: String?
    public var latitude: String = ""
    public var longitude: String = ""
    public var country: String?

    public var ownerId: ObjectId = ""
    public var chapterId: ObjectId = ""

    // MARK: - Initialization

    fileprivate static let requiredProperties = [ParamKey.id]

    public required convenience init?(map: Map) {
        for requiredProperty in Self.requiredProperties {
            if map.JSON[requiredProperty] == nil { return nil }
        }

        self.init()
        self.mapping(map: map)
    }

    public func mapping(map: Map) {
        id <- map[ParamKey.id]
        name <- map[ParamKey.name]
        parentCourseId <- map[ParamKey.parentCourseId]
        description <- map[ParamKey.description]
        type <- map[ParamKey.type]

        // special parsing due to API iconsistencies
        if let mainImageFileName = map.JSON[ParamKey.mainImageFileName] as? String, let backgroundFileName = map.JSON[ParamKey.backgroundFileName] as? String {
            mainImageUrl <- map[ParamKey.mainImageFileName]

            let array = mainImageFileName.components(separatedBy: "mainImage")
            if let baseUrl = array.first {
                backgroundUrl = "\(baseUrl)\(backgroundFileName)"
            }
        } else {
            mainImageUrl <- map[ParamKey.mainImageUrl]
            backgroundUrl <- map[ParamKey.backgroundUrl]
        }

        address <- map[ParamKey.address]
        city <- map[ParamKey.city]
        state <- map[ParamKey.state]
        zip <- map[ParamKey.zip]
        latitude <- map[ParamKey.latitude]
        longitude <- map[ParamKey.longitude]
        country <- map[ParamKey.country]

        ownerId <- map[ParamKey.ownerId]
        chapterId <- map[ParamKey.chapterId]
    }
}
