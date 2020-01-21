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
    case noJoinedRaces
    case noNearbydRaces
    case noRaces
    case noRaceRegisters
    case noChapters
    case noChapterMembers

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
        case .noJoinedRaces:
            text = "You haven't joined any races yet."
        case .noNearbydRaces:
            text = "There are no races in a \(APIServices.shared.settings.searchRadius) miles radius."
        case .noRaceRegisters:
            text = "There are no registered pilots for this race yet."
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
