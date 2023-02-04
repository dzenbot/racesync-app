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
}

fileprivate extension TrackLoader {

    static func loadTracksJSON() -> JSON? {
        guard let path = Bundle.main.path(forResource: "tracks-list", ofType: "json") else { return nil }
        guard let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else { return nil }
        return JSON(parseJSON: jsonString)
    }

    static func parseTrackViewModels(with type: TrackType, from json: JSON) -> [TrackViewModel] {
        let tracks = parseTracks(with: type, from: json)

        let viewModels = TrackViewModel.viewModels(with: tracks).filter { viewModel in
            return viewModel.track.elementsCount > 0
        }
        
        // invert order to show more recent first
        return viewModels.sorted(by: { (c1, c2) -> Bool in
            return c1.track.id.localizedStandardCompare(c2.track.id) == .orderedDescending
        })
    }

    static func parseTracks(with type: TrackType, from json: JSON) -> [Track] {
        guard let array = json.dictionaryObject?[type.rawValue] as? [[String : Any]] else { return [Track]() }

        var tracks = [Track]()
        for dict in array {
            do {
                let track = try Track.init(JSON: dict)
                tracks += [track]
            }  catch {
                Clog.log("error parsing track objects: \(error.localizedDescription)")
            }
        }

        return tracks
    }
}


