//
//  RaceSpecs.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2020-08-26.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation
import Alamofire

public class RaceSpecs: Descriptable {

    public var name: String?

    public init() { }

    func toParameters() -> Parameters {
        var parameters: Parameters = [:]

        if name != nil { parameters[ParameterKey.name] = name }

        return parameters
    }
}
