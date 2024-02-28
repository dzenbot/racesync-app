//
//  ApiError.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-11.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import ObjectMapper

struct ApiError: ImmutableMappable {

    let code: Int
    let message: String

    init(map: Map) throws {
        code = (try? map.value(ParamKey.httpStatus)) ?? -1
        message = try map.value(ParamKey.statusDescription)
    }
}
