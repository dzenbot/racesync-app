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
}
