//
//  JoinButtonAdapter.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-05.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI

public typealias JoinStateCompletionBlock = (_ joinState: JoinState) -> Void

protocol Joinable {
    func toggleJoinButton(_ button: JoinButton, forRaceId raceId: ObjectId, raceApi: RaceApi, _ completion: @escaping JoinStateCompletionBlock)
    func toggleJoinButton(_ button: JoinButton, forChapterId chapterId: ObjectId, chapterApi: ChapterApi, _ completion: @escaping JoinStateCompletionBlock)
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

    func toggleJoinButton(_ button: JoinButton, forRaceId raceId: ObjectId, raceApi: RaceApi, _ completion: @escaping JoinStateCompletionBlock) {

        let state = button.joinState
        let newState = state.inverted

        if state == .joined {
            ActionSheetUtil.presentDestructiveActionSheet(withTitle: "Are you sure about resigning from this race?", message: nil, destructiveTitle: "Yes, Resign") { (action) in
                button.isLoading = true
                raceApi.resign(race: raceId) { (status, error) in
                    button.isLoading = false
                    if status == true {
                        button.joinState = newState
                        completion(newState)
                    } else {
                        completion(state)
                        AlertUtil.presentAlertMessage("Couldn't resign from this race. Please try again later.", title: "Error")
                    }
                }
            }
        } else if state == .join  {
            button.isLoading = true
            raceApi.join(race: raceId) { (status, error) in
                button.isLoading = false
                if status == true {
                    button.joinState = newState
                    completion(newState)
                    AlertUtil.presentAlertMessage("You have joined the race! How bold of you!", title: "Joined Race")
                } else {
                    completion(state)
                    AlertUtil.presentAlertMessage("Couldn't join this race. Please try again later.", title: "Error")
                }
            }
        }
    }

    func toggleJoinButton(_ button: JoinButton, forChapterId chapterId: ObjectId, chapterApi: ChapterApi, _ completion: @escaping JoinStateCompletionBlock) {

        let state = button.joinState
        let newState = state.inverted

        if state == .joined {

        } else if state == .join  {
            
        }
    }
}
