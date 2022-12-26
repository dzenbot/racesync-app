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
    public var urlName: String = ""
    public var parentCourseId: String = ""
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

    public var ownerId: String = ""
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
        parentCourseId <- map["parentCourseId"]
        description <- map["description"]
        type <- map["type"]

        // special parsing due to API iconsistencies
        if let mainImageFileName = map.JSON["mainImageFileName"] as? String, let backgroundFileName = map.JSON["backgroundFileName"] as? String {
            mainImageUrl <- map["mainImageFileName"]

            let array = mainImageFileName.components(separatedBy: "mainImage")
            if let baseUrl = array.first {
                backgroundUrl = "\(baseUrl)\(backgroundFileName)"
            }
        } else {
            mainImageUrl <- map["mainImageUrl"]
            backgroundUrl <- map["backgroundUrl"]
        }

        address <- map["address"]
        city <- map["city"]
        state <- map["state"]
        zip <- map["zip"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        country <- map["country"]

        ownerId <- map["ownerId"]
        chapterId <- map["chapterId"]
    }

}
