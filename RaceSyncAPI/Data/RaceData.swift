//
//  RaceData.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2022-12-27.
//  Copyright © 2022 MultiGP Inc. All rights reserved.
//

import Foundation
import Alamofire

public struct RaceData: Descriptable {

    public var name: String? = nil
    public var startDateString: String? = nil
    public var endDateString: String? = nil
    public var chapterId: String
    public var chapterName: String

    // Default race values, useful for new race creation
    public var raceClass: String = RaceClass.open.rawValue
    public var format: String = ScoringFormat.fastest3Laps.rawValue
    public var qualifying: String = QualifyingType.controlled.rawValue
    public var privacy: String = EventType.public.rawValue
    public var status: String = RaceStatus.open.rawValue
    public var funfly: Bool = false
    public var timing: Bool = true
    public var rounds: Int32 = 5

    public var seasonId: String? = nil
    public var seasonName: String? = nil
    public var courseId: String? = nil
    public var courseName: String? = nil
    public var shortDesc: String? = nil
    public var longDesc: String? = nil
    public var itinerary: String? = nil

    public var raceId: String? = nil

    // To be used to broadcast email and/or APNS after saving
    // See php code base that needs to be implemented on the API side
    // https://github.com/MultiGP/multigp-com/blob/09841623ae274fa8f62a3a4df1393cf1cf986b74/public_html/mgp/protected/modules/multigp/models/Race.php#L311
    public var sendNotification: Bool = false

    public init(with chapterId: ObjectId, chapterName: String) {
        self.chapterId = chapterId
        self.chapterName = chapterName
    }

    public init(with race: Race) {
        self.name = race.name
        self.chapterId = race.chapterId
        self.chapterName = race.chapterName

        if let date = race.startDate {
            self.startDateString = DateUtil.standardDateFormatter.string(from: date)
        }
        if let date = race.endDate {
            self.endDateString = DateUtil.standardDateFormatter.string(from: date)
        }

        self.raceClass = race.raceClass.rawValue
        self.format = race.scoringFormat.rawValue
        self.qualifying = race.disableSlotAutoPopulation.rawValue
        self.privacy = race.type.rawValue
        self.status = race.status.rawValue

        self.funfly = race.scoringDisabled
        self.timing = race.captureTimeEnabled
        self.rounds = race.cycleCount
        self.seasonId = race.seasonId
        self.seasonName = race.seasonName
        self.courseId = race.courseId
        self.courseName = race.courseName
        self.shortDesc = race.description
        self.longDesc = race.content
        self.itinerary = race.itinerary

        self.raceId = race.id
    }

    func toParams() -> Params {
        var params: Params = [:]

        if name != nil { params[ParamKey.name] = name }
        if startDateString != nil { params[ParamKey.startDate] = startDateString }

        params[ParamKey.endDate] = endDateString
        params[ParamKey.chapterId] = chapterId
        params[ParamKey.chapterName] = chapterName

        params[ParamKey.raceClass] = raceClass
        params[ParamKey.scoringFormat] = format
        params[ParamKey.type] = privacy
        params[ParamKey.status] = status
        params[ParamKey.disableSlotAutoPopulation] = qualifying

        // set a default values for ZippyQ
        if qualifying == QualifyingType.open.rawValue {
            params[ParamKey.maxZippyqDepth] = 5
            params[ParamKey.zippyqIterator] = 0
            params[ParamKey.maxBatteriesForQualifying] = 10
        }

        params[ParamKey.scoringDisabled] = funfly
        params[ParamKey.captureTimeEnabled] = timing
        params[ParamKey.cycleCount] = rounds

        if seasonId != nil { params[ParamKey.seasonId] = seasonId }
        if courseId != nil { params[ParamKey.courseId] = courseId }

        params[ParamKey.description] = shortDesc
        params[ParamKey.content] = longDesc
        params[ParamKey.itineraryContent] = itinerary

        params[ParamKey.sendNotification] = sendNotification

        return params
    }

    func toDiffParams(_ beforeData: RaceData) -> Params {
        let before = beforeData.toParams()
        let after = toParams()
        return before.diff(with: after)
    }
}

extension RaceData {

    public var startDate: Date? {
        get {
            guard let str = startDateString else { return nil }
            return DateUtil.standardDateFormatter.date(from: str)
        }
        set { }
    }

    public var endDate: Date? {
        get {
            guard let str = endDateString else { return nil }
            return DateUtil.standardDateFormatter.date(from: str)
        }
        set { }
    }
}
