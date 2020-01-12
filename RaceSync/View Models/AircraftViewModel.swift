//
//  AircraftViewModel.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-10.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI
import CoreLocation

class AircraftViewModel: Descriptable {

    let aircraftId: ObjectId
    let displayName: String
    let imageUrl: String?
    let isGeneric: Bool

    init(with aircraft: Aircraft) {
        self.aircraftId = aircraft.id
        self.displayName = aircraft.name
        self.imageUrl = aircraft.mainImageUrl
        self.isGeneric = false
    }

    init(genericWith title: String) {
        self.aircraftId = ""
        self.displayName = title
        self.imageUrl = nil
        self.isGeneric = true
    }

    static func viewModels(with aircrafts:[Aircraft]) -> [AircraftViewModel] {
        var viewModels = [AircraftViewModel]()
        for aircraft in aircrafts {
            viewModels.append(AircraftViewModel(with: aircraft))
        }
        return viewModels
    }
}
