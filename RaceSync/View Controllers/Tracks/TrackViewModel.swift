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

    /// Returns a string appending a list of localized element names and count
    static func subtitleLabelString(for track: Track) -> String? {
        var strings = [String]()

        for e in track.elements {
            strings += ["\(e.count) \(e.type.title(with: e.count))"]
        }

        return strings.joined(separator: ", ")
    }

    /// Returns a pretty  formated date without time (MMM d, yyyy)
    static func dateLabelString(for date: Date?) -> String? {
        guard let date = date else { return nil }
        return DateUtil.displayDateFormatter.string(from: date)
    }
}

public extension TrackElementType {

    /// Returns the title of an element, pluralized if needed
    func title(with count: Int) -> String {
        var string = self.title
        if count > 1 { string += "s" } // plural
        return string
    }

    /// Returns the thumnail of an element, if available
    var thumbnail: UIImage? {
        return UIImage(named: "track_element_\(self.rawValue)")
    }
}

