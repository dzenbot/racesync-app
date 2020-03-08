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
    func join(race: Race, raceApi: RaceApi, _ completion: @escaping JoinStateCompletionBlock)
    func resign(race: Race, raceApi: RaceApi, _ completion: @escaping JoinStateCompletionBlock)

    // convenience methods, when using a JoinButton instance
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

    func join(race: Race, raceApi: RaceApi, _ completion: @escaping JoinStateCompletionBlock) {

        let aircraftPicker = AircraftPickerController.showAircraftPicker(for: race)

        aircraftPicker.didSelect = { (aircraftId) in
            raceApi.join(race: race.id, aircraftId: aircraftId) { (status, error) in
                if status == true {
                    completion(.joined)

                    // when joining a race, we checkin to get a frequency assigned
                    raceApi.checkIn(race: race.id) { (raceEntry, error) in
                        if let entry = raceEntry, var raceEntries = race.entries {
                            raceEntries += [entry]
                        }
                    }
                } else if let error = error {
                    completion(.join)
                    AlertUtil.presentAlertMessage("Couldn't join this race. Please try again later. \(error.localizedDescription)", title: "Error", delay: 0.5)
                } else {
                    completion(.join)
                }
            }
        }

        aircraftPicker.didError = {
            AlertUtil.presentAlertMessage("Couldn't join this race. Please try again later.", title: "Error", delay: 0.5)
        }

        aircraftPicker.didCancel = {
            completion(.join)
        }
    }

    func resign(race: Race, raceApi: RaceApi, _ completion: @escaping JoinStateCompletionBlock) {

        ActionSheetUtil.presentDestructiveActionSheet(withTitle: "Resign from this race?",
                                                      destructiveTitle: "Yes, Resign",
                                                      completion: { (action) in
                                                        raceApi.resign(race: race.id) { (status, error) in
                                                            if status == true {
                                                                completion(.join)
                                                            } else {
                                                                completion(.joined)
                                                                AlertUtil.presentAlertMessage("Couldn't resign from this race. Please try again later.", title: "Error", delay: 0.5)
                                                            }
                                                        }
        }) { (action) in
            completion(.joined)
        }
    }

    func toggleJoinButton(_ button: JoinButton, forRace race: Race, raceApi: RaceApi, _ completion: @escaping JoinStateCompletionBlock) {

        button.isLoading = true
        let state = button.joinState

        if state == .joined {
            resign(race: race, raceApi: raceApi) { (newState) in

                if state != newState {
                    race.isJoined = false
                    button.joinState = newState
                }

                button.isLoading = false
                completion(newState)
            }
        } else if state == .join  {
            join(race: race, raceApi: raceApi) { (newState) in

                if state != newState {
                    race.isJoined = true
                    button.joinState = newState
                }

                button.isLoading = false
                completion(newState)
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
