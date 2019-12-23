//
//  RSAPIConstants.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-10.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation

public typealias ObjectId = String

public protocol enumTitle {
    var title: String { get }
}

public enum EndPoint {
    static let userLogin = "user/login"
    static let userLogout = "user/logout"
    static let userProfile = "user/profile"
    static let userSearch = "user/search"
    static let raceList = "race/list"
    static let raceListForChapter = "race/listForChapter"
    static let raceFindLocal = "race/findLocal"
    static let raceView = "race/view"
    static let raceViewSimple = "race/viewSimple"
    static let raceJoin = "race/join"
    static let raceResign = "race/resign"
    static let chapterList = "chapter/list"
    static let chapterFindLocal = "chapter/findLocal"
}

public enum ParameterKey {
    static let apiKey = "apiKey"
    static let sessionId = "sessionId"
    static let data = "data"
    static let id = "id"
    static let username = "username"
    static let password = "password"
    static let currentPage = "currentPage"
    static let pageSize = "pageSize"
    static let pilotId = "pilotId"
    static let joined = "joined"
    static let upcoming = "upcoming"
    static let past = "past"
    static let status = "status"
    static let limit = "limit"
    static let orderByDistance = "orderByDistance"
    static let nearBy = "nearBy"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let radius = "radius"
    static let chapterId = "chapterId"
    static let userName = "userName"

}
