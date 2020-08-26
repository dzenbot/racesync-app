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

    public init(with race: Race) {

    }

    public init() { }

    func toParameters() -> Parameters {
        let parameters: Parameters = [:]
        return parameters
    }
}
