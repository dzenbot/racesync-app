//
//  User.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-14.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class User: Mappable, Descriptable {

    public var id: ObjectId = ""
    public var userName: String = ""
    public var displayName: String = ""
    public var firstName: String = ""
    public var lastName: String = ""
    public var profilePictureUrl: String?
    public var profileBackgroundUrl: String?
    public var authType: String = ""
    public var url: String = ""

    public var city: String?
    public var state: String?
    public var country: String?
    public var latitude: String = ""
    public var longitude: String = ""

    public var chapterCount: Int64 = 0
    public var raceCount: Int64 = 0

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
        userName <- map[ParameterKey.userName]
        displayName <- map["displayName"]
        firstName <- map["firstName"]
        lastName <- map["lastName"]
        profilePictureUrl <- map["profilePictureUrl"]
        profileBackgroundUrl <- map["profileBackgroundUrl"]
        authType <- map["authType"]
        url = "https://www.multigp.com/pilots/view/?pilot=\(userName)"

        city <- map["city"]
        state <- map["state"]
        country <- map["country"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]

        chapterCount <- (map["chapterCount"], IntegerTransform())
        raceCount <- (map["raceCount"], IntegerTransform())
    }
}
