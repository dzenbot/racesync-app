//
//  RaceTabbable.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-03-22.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI

protocol RaceTabbable {
    var race: Race { get set }
    func reloadContent()
}
