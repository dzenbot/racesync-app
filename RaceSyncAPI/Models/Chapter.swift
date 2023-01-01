//
//  Chapter.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-20.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class Chapter: Mappable, Joinable, Descriptable {

    public var id: ObjectId = ""
    public var name: String = ""
    public var tier: String?
    public var url: String = ""
    public var urlName: String = ""
    public var description: String = ""
    public var isJoined: Bool = false
    public var mainImageUrl: String? //mainImageFileName
    public var backgroundUrl: String? //backgroundFileName

    public var phone: String = ""
    public var websiteUrl: String = ""
    public var facebookUrl: String?
    public var googleUrl: String?
    public var twitterUrl: String?
    public var youtubeUrl: String?
    public var instagramUrl: String?
    public var meetupUrl: String?

    public var address: String?
    public var city: String?
    public var state: String?
    public var country: String?
    public var zip: String?
    public var latitude: String = ""
    public var longitude: String = ""
    public var distance: String? // available with chapter/findLocal

    public var ownerId: ObjectId = ""
    public var ownerUserName: String = ""

    public var memberCount: Int32 = 0
    public var raceCount: Int32 = 0

    // MARK: - Initialization

    fileprivate static let requiredProperties = [ParamKey.id, ParamKey.name]

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
        tier <- map[ParamKey.tier]
        url = MGPWeb.getUrl(for: .chapterView, value: name)
        urlName <- map[ParamKey.urlName]
        description <- map[ParamKey.description]
        isJoined <- map[ParamKey.isJoined]

        // special parsing due to API iconsistencies
        if let mainImageFileName = map.JSON[ParamKey.mainImageFileName] as? String, let backgroundFileName = map.JSON[ParamKey.backgroundFileName] as? String {
            mainImageUrl <- map[ParamKey.mainImageFileName]

            let array = mainImageFileName.components(separatedBy: ParamKey.mainImage)
            if let baseUrl = array.first {
                backgroundUrl = "\(baseUrl)\(backgroundFileName)"
            }
        } else {
            mainImageUrl <- map[ParamKey.mainImageUrl]
            backgroundUrl <- map[ParamKey.backgroundUrl]
        }

        phone <- map[ParamKey.phone]
        websiteUrl <- map[ParamKey.url]
        facebookUrl <- map[ParamKey.facebookUrl]
        googleUrl <- map[ParamKey.googleUrl]
        twitterUrl <- map[ParamKey.twitterUrl]
        youtubeUrl <- map[ParamKey.youtubeUrl]
        instagramUrl <- map[ParamKey.instagramUrl]
        meetupUrl <- map[ParamKey.meetupUrl]

        address <- map[ParamKey.address]
        city <- map[ParamKey.city]
        state <- map[ParamKey.state]
        country <- map[ParamKey.country]
        zip <- map[ParamKey.zip]
        latitude <- map[ParamKey.latitude]
        longitude <- map[ParamKey.longitude]

        ownerId <- map[ParamKey.ownerId]
        ownerUserName <- map[ParamKey.ownerUserName]

        raceCount <- (map[ParamKey.raceCount], IntegerTransform())
        memberCount <- (map[ParamKey.memberCount], IntegerTransform())
    }
}
