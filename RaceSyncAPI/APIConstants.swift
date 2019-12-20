//
//  RSAPIConstants.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-10.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation

public typealias ObjectId = String

public enum RaceType: Int {
    case normal = 1
    case qualifier = 2
    case final = 3

    public var title: String {
        switch self {
        case .qualifier:    return "Regional Qualifier"
        case .final:        return "Regional Final"
        default:            return "Normal"
        }
    }
}

public enum RaceStatus: String {
    case open = "Open"
    case closed = "Closed"
}

public enum ChapterTier: Int {
    case one = 1
    case two = 2
    case three = 3
    case four = 4
    case provisional = 5

    public var title: String {
        switch self {
        case .one:          return "Tier 1"
        case .two:          return "Tier 2"
        case .three:        return "Tier 3"
        case .four:         return "Special"
        case .provisional:  return "Provisional"
        }
    }
}

public enum RoundType { }

public enum AircraftType: String {
    case tri = "Tri"
    case quad = "Quad"
    case hex = "Hex"
    case octo = "Octo"
    case winged = "Winged"
    case other = "Other"
}

public enum AircraftSize: String {
    case from120 = "120-149"
    case from150 = "150-179"
    case from180 = "180-219"
    case from220 = "220-249"
    case from250 = "250-279"
    case from280 = "280-299"
    case from330 = "330-399"
    case from400 = "400-449"
    case from450 = "450-499"
    case from500 = "500"
}

public enum WingSize: String {
    case from450 = "450"
    case from600 = "600"
    case from900 = "900"
    case from1200 = "1200"
}

public enum VideoTxType: String {
    case ´900mhz´ = "900 mhz"
    case ´1300mhz´ = "1.3 GHz"
    case ´2400mhz´ = "2.4 GHz"
    case ´5800mhz´ = "5.8 GHz"
}

public enum VideoTxPower: String {
    case ´10mw´ = "10 mw"
    case ´50mw´ = "50 mw"
    case ´200mw´ = "200 mw"
    case ´250mw´ = "250 mw"
    case ´400mw´ = "400 mw"
    case ´600mw´ = "600 mw"
    case ´1000mw´ = "1000 mw"
}

public enum VideoChannels: String {
    case fatshark = "Immersion / Fatshark 8 Channel"
    case boscam8 = "Boscam 8 Channel"
    case boscam32 = "Boscam 32 Channel"
    case raceband40 = "Raceband 40"
}

public enum AntennaPolarization: String {
    case lhcp = "Left"
    case rhcp = "Right"
    case both = "Both"
}

public enum BatteryCellType: String {
    case ´2s´ = "2 cell"
    case ´3s´ = "3 cell"
    case ´4s´ = "4 cell"
    case ´5s´ = "5 cell"
    case ´6s´ = "6 cell"
    case ´8s´ = "8 cell"
    case ´12s´ = "12 cell"
}

public enum PropellerSize: String {
    case ´2in´ = "2 inch"
    case ´2in5´ = "2.5 inch"
    case ´3in´ = "3 inch"
    case ´4in´ = "4 inch"
    case ´5in´ = "5 inch"
    case ´6in´ = "6 inch"
    case ´7in´ = "7 inch"
    case ´8in´ = "8 inch"
    case ´9in´ = "9 inch"
    case ´10in´ = "10 inch"
    case ´13in´ = "13 inch"
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
