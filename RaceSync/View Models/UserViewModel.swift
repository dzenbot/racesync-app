//
//  UserViewModel.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-10.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import RaceSyncAPI

class UserViewModel: Descriptable {

    let user: User?
    let raceEntry: RaceEntry?

    let username: String
    let pilotName: String
    let displayName: String
    let pictureUrl: String?

    init(with user: User) {
        self.user = user
        self.raceEntry = nil

        self.username = user.userName
        self.pilotName = ViewModelHelper.titleLabel(for: user.userName, country: user.country)
        self.displayName = user.displayName
        self.pictureUrl = user.profilePictureUrl
    }

    static func viewModels(with users:[User]) -> [UserViewModel] {
        var viewModels = [UserViewModel]()
        for user in users {
            viewModels.append(UserViewModel(with: user))
        }
        return viewModels
    }

    init(with raceEntry: RaceEntry) {
        self.user = nil
        self.raceEntry = raceEntry

        self.username = raceEntry.userName
        self.pilotName = ViewModelHelper.titleLabel(for: raceEntry.userName)
        self.displayName = raceEntry.displayName
        self.pictureUrl = raceEntry.profilePictureUrl
    }

    static func viewModels(with raceEntries:[RaceEntry]) -> [UserViewModel] {
        var viewModels = [UserViewModel]()
        for raceEntry in raceEntries {
            viewModels.append(UserViewModel(with: raceEntry))
        }
        return viewModels
    }
}
