//
//  Joinable.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2020-03-23.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation

public protocol Joinable {
    var id: ObjectId { get }
    var isJoined: Bool { get set }
}

public enum JoinableType {
    case race, chapter
}
