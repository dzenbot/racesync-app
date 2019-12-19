//
//  Random.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-17.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation

private let letters: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

public class Random {

    public static func int(length len: Int = 16) -> Int {
        var rand: Int = 0
        #if os(Linux)
        rand = Int(random() % len)
        #else
        rand = Int(arc4random_uniform(UInt32(len)))
        #endif
        return rand
    }

    public static func float(length len: Int = 16, decimal: Int = 9) -> Float {
        var rand: Float = 0
        #if os(Linux)
        rand = Int(random() % len)
        #else
        rand = Float(arc4random_uniform(UInt32(len))) + Float(arc4random_uniform(UInt32(decimal))) / 10
        #endif
        return rand
    }

    public static func string(length len: Int = 16) -> String {
        let length = letters.count

        var randomString: String = ""
        for _ in 1...len {
            let rand: Int = int(length: length)
            let index = letters.index(letters.startIndex, offsetBy: rand)
            let character = letters[index]
            randomString.append(character)
        }

        return randomString
    }

    public static func requestId() -> String {
        return string()
    }
}
