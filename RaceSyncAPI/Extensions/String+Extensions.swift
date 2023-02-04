//
//  String+Extensions.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2021-01-07.
//  Copyright © 2021 MultiGP Inc. All rights reserved.
//

import Foundation

public extension String {

    func lowercasedWords() -> [String] {
        return self.lowercased().components(separatedBy: " ")
    }

    // Returns a substring to specific limit or the max character count
    // without throwing an exception
    func safeSubstring(to index: Int) -> String {
        let idx = (index > count) ? count : index
        let str = self
        return String(str[..<str.index(str.startIndex, offsetBy: idx)])
    }

    /// A string with the ' characters in it escaped.
    /// Used when passing a string into JavaScript, so the string is not completed too soon
    var escaped: String {
        let unicode = self.unicodeScalars
        var newString = ""
        for char in unicode {
            if char.value == 39 || // 39 == ' in ASCII
                char.value < 9 ||  // 9 == horizontal tab in ASCII
                (char.value > 9 && char.value < 32) // < 32 == special characters in ASCII
            {
                let escaped = char.escaped(asASCII: true)
                newString.append(escaped)
            } else {
                newString.append(String(char))
            }
        }
        return newString
    }
}
