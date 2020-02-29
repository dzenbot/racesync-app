//
//  Chapter.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-20.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class Chapter: Mappable, Descriptable {

    public var id: ObjectId = ""
    public var name: String = ""
    public var tier: String?
    public var url: String = ""
    public var urlName: String = ""
    public var description: String = ""
    public var mainImageUrl: String? //mainImageFileName
    public var backgroundUrl: String? //backgroundFileName

    public var raceCount: String?
    public var memberCount: String?

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

    // MARK: - Initialization

    fileprivate static let requiredProperties = ["id", "name"]

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
        tier <- map["tier"]
        url = "\(MGPWeb.getUrl(for: .chapterView))=\(name)"
        urlName <- map["urlName"]
        description <- map["description"]

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

        raceCount <- map["raceCount"]
        memberCount <- map["memberCount"]

        websiteUrl <- map["url"]
        facebookUrl <- map["facebookUrl"]
        googleUrl <- map["googleUrl"]
        twitterUrl <- map["twitterUrl"]
        youtubeUrl <- map["youtubeUrl"]
        instagramUrl <- map["instagramUrl"]
        meetupUrl <- map["meetupUrl"]

        address <- map["address"]
        city <- map["city"]
        state <- map["state"]
        country <- map["country"]
        zip <- map["zip"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]

        ownerId <- map["ownerId"]
        ownerUserName <- map["ownerUserName"]
    }
}
