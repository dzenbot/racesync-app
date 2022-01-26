//
//  TrackLoader.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2022-01-25.
//  Copyright © 2022 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI
import SwiftyJSON

class TrackLoader {

    static func getTrackViewModels(with type: TrackType) -> [TrackViewModel] {
        guard let json = loadTracksJSON() else { return [TrackViewModel]() }
        return parseTrackViewModels(with: type, from: json)
    }

    static func thisYearSeriesTrack() -> TrackViewModel? {
        return nil
    }

    static func isThisYearSeriesActive() -> Bool {
        return false
    }
}

fileprivate extension TrackLoader {

    static func loadTracksJSON() -> JSON? {
        guard let path = Bundle.main.path(forResource: "track-list", ofType: "json") else { return nil }
        guard let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else { return nil }

        return JSON(parseJSON: jsonString)
    }

    static func parseTrackViewModels(with type: TrackType, from json: JSON) -> [TrackViewModel] {
        guard let array = json.dictionaryObject?[type.rawValue] as? [[String : Any]] else { return [TrackViewModel]() }

        var tracks = [Track]()
        for dict in array {
            if let track = Track.init(JSON: dict) {
                if track.elementsCount == 0 { continue } // skip track with no elements (dummies)
                tracks += [track]
            }
        }

        // invert order to show more recent first
        let sortedTracks = tracks.sorted(by: { (c1, c2) -> Bool in
            return c1.id.localizedStandardCompare(c2.id) == .orderedDescending
        })

        return TrackViewModel.viewModels(with: sortedTracks)
    }
}


