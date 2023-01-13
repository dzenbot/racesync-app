//
//  RaceData.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2022-12-27.
//  Copyright © 2022 MultiGP Inc. All rights reserved.
//

import Foundation
import Alamofire

public class RaceData: Descriptable {

    public var name: String? = nil
    public var startDateString: String? = nil
    public var endDateString: String? = nil
    public var chapterId: String
    public var chapterName: String

    public var raceClass: String = RaceClass.open.rawValue
    public var format: String = ScoringFormat.aggregateLap.rawValue
    public var qualifying: String = QualifyingType.controlled.rawValue
    public var privacy: String = EventType.public.rawValue
    public var status: String = RaceStatus.closed.rawValue

    public var funfly: Bool = false
    public var timing: Bool = true
    public var rounds: Int32 = 5
    public var seasonId: String? = nil
    public var seasonName: String? = nil
    public var locationId: String? = nil
    public var locationName: String? = nil
    public var shortDesc: String? = nil
    public var longDesc: String? = nil
    public var itinerary: String? = nil

    public var raceId: String? = nil

    public init(with chapterId: ObjectId, chapterName: String) {
        self.chapterId = chapterId
        self.chapterName = chapterName
    }

    public init(with race: Race) {
        self.name = race.name
        self.chapterId = race.chapterId
        self.chapterName = race.chapterName

        if let date = race.startDate {
            self.startDateString = DateUtil.isoDateFormatter.string(from: date)
        }
        if let date = race.endDate {
            self.endDateString = DateUtil.isoDateFormatter.string(from: date)
        }

        self.raceClass = race.raceClass?.rawValue ?? ""
        self.format = race.scoringFormat.rawValue
        self.qualifying = race.disableSlotAutoPopulation.rawValue
        self.privacy = race.type.rawValue
        self.status = race.status.rawValue

        self.funfly = race.scoringDisabled
        self.timing = race.captureTimeEnabled
        self.rounds = race.cycleCount
        self.seasonId = race.seasonId
        self.seasonName = race.seasonName
        self.locationId = race.courseId
        self.locationName = race.courseName
        self.shortDesc = race.description
        self.longDesc = race.content
        self.itinerary = race.itineraryContent

        self.raceId = race.id
    }

    func toParameters() -> Parameters {
        var params: Parameters = [:]

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
        if locationId != nil { params[ParamKey.locationId] = locationId }

        params[ParamKey.description] = shortDesc
        params[ParamKey.content] = longDesc
        params[ParamKey.itineraryContent] = itinerary

        return params
    }
}

extension RaceData {

    public var startDate: Date? {
        get {
            guard let str = startDateString else { return nil }
            return DateUtil.isoDateFormatter.date(from: str)
        }
        set { }
    }

    public var endDate: Date? {
        get {
            guard let str = endDateString else { return nil }
            return DateUtil.isoDateFormatter.date(from: str)
        }
        set { }
    }
}
