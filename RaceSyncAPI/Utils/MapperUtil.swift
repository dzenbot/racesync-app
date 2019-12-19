//
//  MapperUtil.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-18.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import ObjectMapper

public class MapperUtil {

    public static let dateTransform = TransformOf<Date, String>(fromJSON: { (value: String?) -> Date? in
        guard let value = value else { return nil }
        return DateUtil.deserializeJSONDate(value)
    }) { (_: Date?) -> String? in
        return nil
    }
}
