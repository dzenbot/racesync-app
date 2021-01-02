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
    case noRaceRegisters
    case noRaceResults
    case noChapters
    case noChapterMembers

    case noProfileRaces
    case noProfileChapters
    case noMyProfileRaces
    case noMyProfileChapters

    case noAircrafts
    case noMyAircrafts
    case noMatchingAircrafts

    case commingSoon

    case noSearchResults
    case errorRaces
    case errorChapters
    case errorUsers
    case errorAircrafts

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
        case .noAircrafts, .noMyAircrafts:
            text = "No Aircrafts"
        case .noMatchingAircrafts:
            text = "No Matching Aircrafts"
        case .commingSoon:
            text = "Coming Soon"
        case .noSearchResults:
            text = "No Results"
        case .errorRaces, .errorAircrafts:
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
            text = "You haven't joined any races yet."
        case .noNearbydRaces:
            text = "There are no races in a \(settings.searchRadius)\(settings.lengthUnit.symbol) radius."
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
        case .noAircrafts:
            text = "This user doesn't have any aircrafts yet."
        case .noMyAircrafts:
            text = "You don't have any aircrafts yet."
        case .noMatchingAircrafts:
            text = "You don't have any aircrafts matching the race requirements."
        case .commingSoon:
            text = "This section is under development."
        case .errorRaces:
            text = "Could not load the race details.\nPlease try again later or report a bug."
        case .errorAircrafts:
            text = "Could not load the aircrafts.\nPlease try again later or report a bug."
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
        case .noRaceRegisters:
            text = "Join Race"
        case .noMyAircrafts, .noMatchingAircrafts:
            text = "Add Aircraft"
        case .errorRaces, .errorAircrafts:
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
