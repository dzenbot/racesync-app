//
//  RaceSchedule.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2024-12-19.
//  Copyright © 2024 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper

public class RaceSchedule: Mappable {
    public var rounds: [RaceRound] = []

    public required init?(map: Map) {}

    public func mapping(map: Map) {
        rounds <- map["rounds"]
    }
}

public class RaceHeat: Mappable {
    public var name: String?
    public var `entries`: [ResultEntry] = []

    public required init?(map: Map) {}

    public func mapping(map: Map) {
        name <- map["name"]
        entries <- map["entries"]
    }
}

public class RaceRound: Mappable {
    public var name: String?
    public var number: String?
    public var heats: [RaceHeat] = []

    public required init?(map: Map) {}

    public func mapping(map: Map) {
        name <- map["name"]
        number = name?.extractNumber()
        heats <- map["heats"]
    }
}


