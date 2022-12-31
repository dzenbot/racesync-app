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
    public var date: String? = nil
    public var chapterId: String
    public var chapterName: String

    public var `class`: String = RaceClass.open.rawValue
    public var format: String = ScoringFormats.fastest3Laps.rawValue
    public var schedule: String = RaceSchedule.controlled.rawValue
    public var privacy: String = EventType.public.rawValue
    public var status: String = RaceStatus.closed.rawValue

    public var funfly: Bool = false
    public var timing: Bool = true
    public var rounds: Int = 5
    public var seasonId: String? = nil
    public var seasonName: String? = nil
    public var locationId: String? = nil
    public var locationName: String? = nil
    public var shortDesc: String? = nil
    public var longDesc: String? = nil
    public var itinerary: String? = nil

    public init(with chapterId: ObjectId, chapterName: String) {
        self.chapterId = chapterId
        self.chapterName = chapterName
    }

    func toParameters() -> Parameters {
        var parameters: Parameters = [:]

        if name != nil { parameters[ParamKey.name] = name }
        if date != nil { parameters[ParamKey.startDate] = date }
        
        parameters[ParamKey.chapterId] = chapterId
        parameters[ParamKey.chapterId] = chapterName

        parameters[ParamKey.class] = self.class
        parameters[ParamKey.scoringFormat] = format
        parameters[ParamKey.status] = status

        parameters[ParamKey.scoringDisabled] = funfly
        parameters[ParamKey.captureTimeEnabled] = timing
        parameters[ParamKey.cycleCount] = rounds

        if seasonId != nil { parameters[ParamKey.seasonId] = seasonId }
        if locationId != nil { parameters[ParamKey.locationId] = locationId }

        return parameters
    }
}
