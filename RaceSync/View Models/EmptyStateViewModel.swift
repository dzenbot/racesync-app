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

    case commingSoon

    case errorRace
    case errorChapter
    case errorUser

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
        case .commingSoon:
            text = "Coming Soon"
        case .errorRace:
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

        var text: String?

        switch emptyState {
        case .noJoinedRaces, .noMyProfileRaces:
            text = "You haven't joined any races yet."
        case .noNearbydRaces:
            text = "There are no races in a \(APIServices.shared.settings.searchRadius) miles radius."
        case .noRaceRegisters:
            text = "There are no registered pilots for this race yet."
        case .noRaceResults:
            text = "There are no race results available just yet."
        case .noChapterMembers:
            text = "There are no registered members for this chapter yet."
        case .noProfileRaces:
            text = "This user hasn't joined any races yet."
        case .noProfileChapters:
            text = "This user hasn't joined any chapters yet."
        case .noMyProfileChapters:
            text = "You haven't joined any chapters yet."
        case .commingSoon:
            text = "This feature is currently under development."
        case .errorRace:
            text = "Could not load the race details.\nPlease try again later or report a bug."
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
            text = "Adjust Search Radius"
        case .noRaceRegisters:
            text = "Join This Race"
        case .errorRace:
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
