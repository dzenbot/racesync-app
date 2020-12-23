//
//  TrackViewModel.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-02.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation
import UIKit
import RaceSyncAPI

class TrackViewModel: Descriptable {

    let track: Track

    let titleLabel: String
    let subtitleLabel: String?

    let startDateLabel: String?
    let endDateLabel: String?

    // MARK: - Initializatiom

    init(with track: Track) {
        self.track = track

        self.titleLabel = track.title
        self.subtitleLabel = Self.subtitleLabelString(for: track)
        self.startDateLabel = Self.dateLabelString(for: track.startDate) // "Saturday, September 14th"
        self.endDateLabel = Self.dateLabelString(for: track.endDate)
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

    static func dateLabelString(for date: Date?) -> String? {
        guard let date = date else { return nil }
        return DateUtil.displayDateFormatter.string(from: date)
    }
}

public extension TrackElementType {

    func title(with count: Int) -> String {
        var string = self.title
        if count > 1 { string += "s" }
        return string
    }

    var thumbnail: UIImage? {
        return UIImage(named: "track_element_\(self.rawValue)")
    }
}

