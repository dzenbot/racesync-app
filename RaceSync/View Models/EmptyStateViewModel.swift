//
//  EmptyStateViewModel.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-20.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI

protocol EmptyStateViewModelInterface {
    var title: NSAttributedString? { get }
    var description: NSAttributedString? { get }
    var image: UIImage? { get }
    var backgroundColor: UIColor? { get }

    func buttonTitle(_ state: UIControl.State) -> NSAttributedString?
}

enum EmptyState {
    case noRaces
    case noJoinedRaces
    case noNearbydRaces
    case noSeriesRaces
    case noRaceRegisters
    case noRaceResults
    case noChapters
    case noChapterMembers

    case noProfileRaces
    case noProfileChapters
    case noMyProfileRaces
    case noMyProfileChapters

    case noAircraft
    case noMyAircraft
    case noMatchingAircraft

    case commingSoon

    case noSearchResults
    case errorRaces
    case errorChapters
    case errorUsers
    case errorAircraft

    case noInternet
}

struct EmptyStateViewModel: EmptyStateViewModelInterface {

    var emptyState: EmptyState
    var isLoading = false

    init(_ emptyState: EmptyState) {
        self.emptyState = emptyState
    }

    var title: NSAttributedString? {

        var text: String?

        switch emptyState {
        case .noJoinedRaces, .noNearbydRaces:
            text = "No Races Found"
        case .noSeriesRaces:
            text = "No GQ Found"
        case .noRaceRegisters:
            text = "No Registered Pilots"
        case .noRaceResults:
            text = "No Race Results"
        case .noChapterMembers:
            text = "No Chapter Members"
        case .noRaces, .noMyProfileRaces, .noProfileRaces:
            text = "No Races"
        case .noChapters, .noMyProfileChapters, .noProfileChapters:
            text = "No Chapters"
        case .noAircraft, .noMyAircraft:
            text = "No Aircraft"
        case .noMatchingAircraft:
            text = "No Matching Aircraft"
        case .commingSoon:
            text = "Coming Soon"
        case .noSearchResults:
            text = "No Results"
        case .errorRaces, .errorAircraft:
            text = "Error"
        default:
            return nil
        }

        guard let title = text else { return nil }

        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 25)
        attributes[NSAttributedString.Key.foregroundColor] = Color.gray200

        return NSAttributedString.init(string: title, attributes: attributes)
    }

    var description: NSAttributedString? {

        let settings = APIServices.shared.settings
        var text: String?

        switch emptyState {
        case .noRaces:
            text = "There are no races available yet."
        case .noJoinedRaces, .noMyProfileRaces:
            text = "You haven't joined any upcoming races yet."
        case .noSeriesRaces:
            text = "There are no \(Date().thisYear()) GQ available yet."
        case .noNearbydRaces:
            text = "There are no races available in a \(settings.searchRadius)\(settings.lengthUnit.symbol) radius."
        case .noRaceRegisters:
            text = "There are no registered pilots for this race yet."
        case .noRaceResults:
            text = "There are no race results available just yet."
        case .noChapterMembers:
            text = "There are no registered members yet."
        case .noProfileRaces:
            text = "This user hasn't joined any races yet."
        case .noProfileChapters:
            text = "This user hasn't joined any chapters yet."
        case .noMyProfileChapters:
            text = "You haven't joined any chapters yet."
        case .noAircraft:
            text = "This user doesn't have any aircraft yet."
        case .noMyAircraft:
            text = "You don't have any aircraft yet."
        case .noMatchingAircraft:
            text = "You don't have any aircraft matching the race requirements."
        case .commingSoon:
            text = "This section is under development."
        case .errorRaces:
            text = "Could not load the race details.\nPlease try again later or report a bug."
        case .errorAircraft:
            text = "Could not load the aircraft.\nPlease try again later or report a bug."
        default:
            return nil
        }

        guard let title = text else { return nil }

        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: 19)
        attributes[NSAttributedString.Key.foregroundColor] = Color.gray200

        return NSAttributedString.init(string: title, attributes: attributes)
    }

    var image: UIImage? {
        return nil
    }

    func buttonTitle(_ state: UIControl.State) -> NSAttributedString? {

        var text: String?

        switch emptyState {
        case .noJoinedRaces:
            text = "Search Nearby Races"
        case .noNearbydRaces:
            text = "Adjust Radius"
        case .noSeriesRaces:
            text = "View \(Date().lastYear()) GQ Races"
        case .noRaceRegisters:
            text = "Join Race"
        case .noMyAircraft, .noMatchingAircraft:
            text = "Add Aircraft"
        case .errorRaces, .errorAircraft:
            text = "Send Bug Report"
        default:
            return nil
        }

        guard let title = text else { return nil }

        var attributes: [NSAttributedString.Key: Any] = [:]
        attributes[NSAttributedString.Key.font] = UIFont.boldSystemFont(ofSize: 19)

        if state == .highlighted {
            attributes[NSAttributedString.Key.foregroundColor] = Color.red.withAlphaComponent(0.5)
        } else {
            attributes[NSAttributedString.Key.foregroundColor] = Color.red
        }

        return NSAttributedString.init(string: title, attributes: attributes)
    }

    var backgroundColor: UIColor? {
        return Color.white
    }
}
