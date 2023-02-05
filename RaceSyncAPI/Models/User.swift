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

    public var homeChapterId: ObjectId = ""
    public var chapterIds: [ObjectId] = [ObjectId]()
    public var chapterCount: Int32 = 0
    public var raceCount: Int32 = 0
    public var isPublic: Bool = false

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
        userName <- (map[ParamKey.userName], MapperUtil.stringTransform)
        displayName <- (map[ParamKey.displayName], MapperUtil.stringTransform)
        firstName <- (map[ParamKey.firstName], MapperUtil.stringTransform)
        lastName <- (map[ParamKey.lastName], MapperUtil.stringTransform)
        profilePictureUrl <- map[ParamKey.profilePictureUrl]
        profileBackgroundUrl <- map[ParamKey.profileBackgroundUrl]
        authType <- map[ParamKey.authType]
        url = "https://www.multigp.com/pilots/view/?pilot=\(userName)"

        city <- map[ParamKey.city]
        state <- map[ParamKey.state]
        country <- map[ParamKey.country]
        latitude <- map[ParamKey.latitude]
        longitude <- map[ParamKey.longitude]

        homeChapterId <- map[ParamKey.homeChapterId]
        chapterIds <- map[ParamKey.chapterIds]
        chapterCount <- (map[ParamKey.chapterCount], IntegerTransform())
        raceCount <- (map[ParamKey.raceCount], IntegerTransform())
        isPublic <- map[ParamKey.isPublic]
    }
}
