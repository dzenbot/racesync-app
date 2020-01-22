//
//  APIEnvironment.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-21.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation

public enum APIEnvironment: Int {
    case prod, dev

    public var title: String {
        switch self {
        case .prod:     return "Prod"
        case .dev:      return "Dev"
        }
    }
}
