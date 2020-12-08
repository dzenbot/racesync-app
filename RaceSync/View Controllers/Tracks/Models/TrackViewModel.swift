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
        let elements = track.elements

        if elements.gates > 0 {
            var string = "\(elements.gates) gate"
            if elements.gates > 1 {
                string += "s"
            }
            strings += [string]
        }
        if elements.flags > 0 {
            var string = "\(elements.flags) flag"
            if elements.flags > 1 {
                string += "s"
            }
            strings += [string]
        }

        return strings.joined(separator: ", ")
    }
}
