//
//  EnumTitle.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2022-12-27.
//  Copyright © 2022 MultiGP Inc. All rights reserved.
//

import Foundation

public protocol EnumTitle: CaseIterable {
    var title: String { get }
    init?(title: String)
}

extension EnumTitle {
    public init?(title: String) {
        for `case` in Self.allCases {
            if `case`.title == title {
                self = `case`
                return
            }
        }
        return nil
    }
}
