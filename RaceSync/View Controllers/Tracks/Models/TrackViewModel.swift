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
    let subtitleLabel: String?

    // MARK: - Initializatiom

    init(with track: Track) {
        self.track = track

        self.titleLabel = track.title
        self.subtitleLabel = Self.subtitleLabelString(for: track)
    }

    static func viewModels(with objects:[Track]) -> [TrackViewModel] {
        var viewModels = [TrackViewModel]()
        for object in objects {
            viewModels.append(TrackViewModel(with: object))
        }
        return viewModels
    }
}

extension TrackViewModel {

    static func subtitleLabelString(for track: Track) -> String? {
        var strings = [String]()

        for e in track.elements {
            strings += ["\(e.count) \(e.type.title(with: e.count))"]
        }

        return strings.joined(separator: ", ")
    }
}
