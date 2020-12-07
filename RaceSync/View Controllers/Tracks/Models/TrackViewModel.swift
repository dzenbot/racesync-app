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
        guard let elements = track.elements else { return nil }

        var strings = [String]()

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


//        } else if elements.gates > 0 {
//            strings += ["\(elements.gates) gate"]
//        }
//
//        if elements.flags > 1 {
//            strings += ["\(elements.flags) flags"]
//        } else if elements.flags > 0 {
//            strings += ["\(elements.flags) flag"]
//        }

        return strings.joined(separator: ", ")
    }
}


//public struct TrackElements {
//    let gate: Int
//    let flag: Int
//    let tower_gate: Int
//    let double_gate: Int
//    let ladder_gate: Int
//    let topless_ladder_gate: Int
//    let dive_gate: Int
//    let launch_gate: Int
//    let hurtle: Int
//}
