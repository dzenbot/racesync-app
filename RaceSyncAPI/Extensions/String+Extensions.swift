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
}
