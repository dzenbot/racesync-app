//
//  TrackViewModel.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-02.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI

class TrackViewModel: Descriptable {

    let track: Track

    let titleLabel: String
    
    // MARK: - Initializatiom

    init(with track: Track) {
        self.track = track

        self.titleLabel = track.title
    }

    static func viewModels(with objects:[Track]) -> [TrackViewModel] {
        var viewModels = [TrackViewModel]()
        for object in objects {
            viewModels.append(TrackViewModel(with: object))
        }
        return viewModels
    }
}


