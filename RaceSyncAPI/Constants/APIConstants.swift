//
//  RSAPIConstants.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-10.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation

public typealias ObjectId = String

public let StandardPageSize: Int = 100
public let StandardDateFormat: String = "yyyy-MM-dd"
public let StandardDateTimeFormat: String = "yyyy-MM-dd h:mm a"

enum EndPoint {
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
    static let raceForceJoin = "race/forceJoinPilot"
    static let raceOpen = "race/open"
    static let raceClose = "race/close"
    static let raceCheckIn = "race/checkIn"
    static let raceCheckOut = "race/checkOut"
    static let raceCreate = "race/create"

    static let chapterList = "chapter/list"
    static let chapterFindLocal = "chapter/findLocal"
    static let chapterUsers = "chapter/users"
    static let chapterListManaged = "chapter/listManaged"
    static let chapterSearch = "chapter/search"
    static let chapterJoin = "chapter/join"
    static let chapterResign = "chapter/resign"

    static let seasonCreate = "season/create"
    static let seasonSearch = "season/search"
    static let seasonDelete = "season/delete"
    static let seasonList = "season/list"

    static let courseCreate = "course/create"
    static let courseSearch = "course/search"
    static let courseDelete = "course/delete"
    static let courseList = "course/list"

    static let aircraftList = "aircraft/list"
    static let aircraftCreate = "aircraft/create"
    static let aircraftUpdate = "aircraft/update"
    static let aircraftRetire = "aircraft/retire"
    static let aircraftUploadMainImage = "aircraft/uploadMainImage"
    static let aircraftUploadBackground = "aircraft/uploadBackground"
}

enum ParamKey {
    static let apiKey = "apiKey"
    static let authType = "authType"

    static let id = "id"
    static let sessionId = "sessionId"
    static let pilotId = "pilotId"
    static let chapterId = "chapterId"
    static let aircraftId = "aircraftId"
    static let seasonId = "seasonId"
    static let locationId = "locationId"
    static let ownerId = "ownerId"
    static let parentCourseId = "parentCourseId"

    static let contentType = "Content-type"
    static let authorization = "Authorization"
    static let data = "data"
    static let errors = "errors"
    static let description = "description"
    static let statusDescription = "statusDescription"
    static let httpStatus = "httpStatus"
    static let displayName = "displayName"
    static let url = "url"
    static let currentPage = "currentPage"
    static let pageSize = "pageSize"


    static let username = "username"
    static let password = "password"
    static let firstName = "firstName"
    static let lastName = "lastName"
    static let ownerUserName = "ownerUserName"
    static let joined = "joined"
    static let isJoined = "isJoined"
    static let upcoming = "upcoming"
    static let past = "past"
    static let status = "status"
    static let limit = "limit"
    static let orderByDistance = "orderByDistance"
    static let nearBy = "nearBy"
    static let isQualifier = "isQualifier"
    static let userName = "userName"
    static let retired = "retired"
    static let name = "name"
    static let type = "type"
    static let size = "size"
    static let videoTransmitter = "videoTransmitter"
    static let videoTransmitterPower = "videoTransmitterPower"
    static let videoTransmitterChannels = "videoTransmitterChannels"
    static let videoReceiverChannels = "videoReceiverChannels"
    static let battery = "battery"
    static let propSize = "propellerSize"
    static let antenna = "antenna"
    static let chapterName = "chapterName"
    static let managedChapters = "managedChapters"

    static let address = "address"
    static let city = "city"
    static let state = "state"
    static let zip = "zip"
    static let country = "country"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let radius = "radius"



    static let mainImageFileName = "mainImageFileName"
    static let mainImageUrl = "mainImageUrl"
    static let backgroundFileName = "backgroundFileName"
    static let backgroundUrl = "backgroundUrl"
}
