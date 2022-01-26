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

    static func getTracks(with type: TrackType) -> [Track] {
        guard let json = loadTracksJSON() else { return [Track]() }
        return parseTracks(with: type, from: json)
    }

    static func thisYearSeriesTrack() -> Track? {
        let series = TrackLoader.getTracks(with: .gq)
        let thisYearSeries = series.filter { track in
            guard let date = track.startDate else { return false }
            return date.isInThisYear
        }
        
        return thisYearSeries.first
    }

    static func isThisYearSeriesActive() -> Bool {
        let track = thisYearSeriesTrack()
        guard let startDate = track?.startDate, let endDate = track?.endDate else { return false }

        guard let startDateBuffer = startDate.daysFromNow(-30) else { return false }
        guard let endDateBuffer = endDate.daysFromNow(30) else { return false }

        return startDateBuffer.isPassed && !endDateBuffer.isPassed
    }
}

fileprivate extension TrackLoader {

    static func loadTracksJSON() -> JSON? {
        guard let path = Bundle.main.path(forResource: "track-list", ofType: "json") else { return nil }
        guard let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else { return nil }
        return JSON(parseJSON: jsonString)
    }

    static func parseTracks(with type: TrackType, from json: JSON) -> [Track] {
        guard let array = json.dictionaryObject?[type.rawValue] as? [[String : Any]] else { return [Track]() }

        var tracks = [Track]()
        for dict in array {
            if let track = Track.init(JSON: dict) {
                tracks += [track]
            }
        }

        return tracks
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
}


