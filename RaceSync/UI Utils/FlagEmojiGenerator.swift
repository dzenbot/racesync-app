//
//  FlagEmojiGenerator.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-17.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

class FlagEmojiGenerator: NSObject {

    static func flag(country: String?) -> String {
        guard let country = country else { return "" }

        let base : UInt32 = 127397
        var s = ""
        for v in country.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        
        return String(s)
    }
}

