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

    public var name: String?
    public var date: String?

    public var chapterId: String?
    public var chapterName: String?

    public var `class`: String?
    public var format: String?
    public var schedule: String?
    public var privacy: String?
    public var status: String?

    public init() { }

    func toParameters() -> Parameters {
        var parameters: Parameters = [:]

        if name != nil { parameters[ParameterKey.name] = name }
        if chapterId != nil { parameters[ParameterKey.chapterId] = chapterId }

        return parameters
    }
}
