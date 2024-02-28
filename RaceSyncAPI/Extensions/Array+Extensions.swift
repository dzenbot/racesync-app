//
//  Array+Extensions.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2020-07-31.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation

public extension Array {

    mutating func rearrange(from: Int, to: Int) {
        insert(remove(at: from), at: to)
    }
}

public extension Array where Element: Equatable {
    func removingDuplicates() -> Array {
        return reduce(into: []) { result, element in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
}
