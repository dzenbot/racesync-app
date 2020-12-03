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
    let fullName: String
    let pictureUrl: String?

    init(with user: User) {
        self.user = user
        self.raceEntry = nil

        self.username = user.userName
        self.pilotName = ViewModelHelper.titleLabel(for: user.userName, country: user.country)
        self.displayName = user.displayName
        self.fullName = "\(user.firstName.capitalized) \(user.lastName.capitalized)"
        self.pictureUrl = user.profilePictureUrl
    }

    static func viewModels(with objects:[User]) -> [UserViewModel] {
        var viewModels = [UserViewModel]()
        for object in objects {
            viewModels.append(UserViewModel(with: object))
        }
        return viewModels
    }

    init(with raceEntry: RaceEntry) {
        self.user = nil
        self.raceEntry = raceEntry

        self.username = raceEntry.userName
        self.pilotName = ViewModelHelper.titleLabel(for: raceEntry.userName)
        self.displayName = raceEntry.displayName
        self.fullName = "\(raceEntry.firstName.capitalized) \(raceEntry.lastName.capitalized)"
        self.pictureUrl = raceEntry.profilePictureUrl
    }

    static func viewModels(with objects:[RaceEntry]) -> [UserViewModel] {
        var viewModels = [UserViewModel]()
        for object in objects {
            viewModels.append(UserViewModel(with: object))
        }
        return viewModels
    }
}

extension UserViewModel: Comparable {
    static func == (lhs: UserViewModel, rhs: UserViewModel) -> Bool {
        return lhs.username == rhs.username
    }

    static func < (lhs: UserViewModel, rhs: UserViewModel) -> Bool {
        return lhs.username < rhs.username
    }
}
