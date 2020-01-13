//
//  JoinButtonAdapter.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-05.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI
import Presentr

public typealias JoinStateCompletionBlock = (_ joinState: JoinState) -> Void

protocol Joinable {
    func toggleJoinButton(_ button: JoinButton, forRace race: Race, raceApi: RaceApi, _ completion: @escaping JoinStateCompletionBlock)
    func toggleJoinButton(_ button: JoinButton, forChapterId chapter: Chapter, chapterApi: ChapterApi, _ completion: @escaping JoinStateCompletionBlock)
}

public enum JoinState {
    case join, joined, closed

    var title: String {
        switch self {
        case .join:   return "Join"
        case .joined: return "Joined"
        case .closed: return "Closed"
        }
    }

    fileprivate var inverted: JoinState {
        switch self {
        case .join:   return .joined
        case .joined: return .join
        case .closed: return .closed
        }
    }
}

extension Joinable {

    func toggleJoinButton(_ button: JoinButton, forRace race: Race, raceApi: RaceApi, _ completion: @escaping JoinStateCompletionBlock) {

        let state = button.joinState
        let newState = state.inverted

        if state == .joined {
            ActionSheetUtil.presentDestructiveActionSheet(withTitle: "Are you sure about resigning from this race?", destructiveTitle: "Yes, Resign") { (action) in
                button.isLoading = true
                raceApi.resign(race: race.id) { (status, error) in
                    button.isLoading = false
                    if status == true {
                        button.joinState = newState
                        completion(newState)
                    } else {
                        completion(state)
                        AlertUtil.presentAlertMessage("Couldn't resign from this race. Please try again later.", title: "Error", delay: 0.5)
                    }
                }
            }
        } else if state == .join  {
            button.isLoading = true

            let aircraftPicker = AircraftPickerController.showAircraftPicker(for: race)

            aircraftPicker.didSelect = { (aircraftId) in
                raceApi.join(race: race.id, aircraftId: aircraftId) { (status, error) in
                    button.isLoading = false
                    if status == true {
                        button.joinState = newState
                        completion(newState)
                    } else {
                        completion(state)
                        AlertUtil.presentAlertMessage("Couldn't join this race. Please try again later.", title: "Error", delay: 0.5)
                    }
                }
            }

            aircraftPicker.didError = {
                AlertUtil.presentAlertMessage("Couldn't join this race. Please try again later.", title: "Error", delay: 0.5)
            }

            aircraftPicker.didCancel = {
                button.isLoading = false
            }
        }
    }

    func toggleJoinButton(_ button: JoinButton, forChapterId chapter: Chapter, chapterApi: ChapterApi, _ completion: @escaping JoinStateCompletionBlock) {

        let state = button.joinState
        let _ = state.inverted

        if state == .joined {

        } else if state == .join  {
            
        }
    }
}
