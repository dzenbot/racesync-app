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
    public var dateString: String? = nil
    public var chapterId: String
    public var chapterName: String

    public var raceClass: String = RaceClass.open.rawValue
    public var format: String = ScoringFormat.aggregateLap.rawValue
    public var schedule: String = RaceSchedule.controlled.rawValue
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
            self.dateString = DateUtil.isoDateFormatter.string(from: date)
        }

        self.raceClass = race.raceClass?.rawValue ?? ""
        self.format = race.scoringFormat.rawValue
        self.schedule = RaceSchedule.controlled.rawValue // to be defined based on other params
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
        var parameters: Parameters = [:]

        if name != nil { parameters[ParamKey.name] = name }
        if dateString != nil { parameters[ParamKey.startDate] = dateString }
        
        parameters[ParamKey.chapterId] = chapterId
        parameters[ParamKey.chapterName] = chapterName

        parameters[ParamKey.raceClass] = raceClass
        parameters[ParamKey.scoringFormat] = format
        parameters[ParamKey.type] = privacy
        parameters[ParamKey.status] = status

        parameters[ParamKey.scoringDisabled] = funfly
        parameters[ParamKey.captureTimeEnabled] = timing
        parameters[ParamKey.cycleCount] = rounds

        if seasonId != nil { parameters[ParamKey.seasonId] = seasonId }
        if locationId != nil { parameters[ParamKey.locationId] = locationId }

        return parameters
    }
}

extension RaceData {

    public var date: Date? {
        get {
            guard let str = dateString else { return nil }
            return DateUtil.isoDateFormatter.date(from: str)
        }
        set { }
    }
}
