//
//  ProfileViewModel.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-20.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI

class ProfileViewModel: Descriptable {

    let type: ProfileViewModelType
    let id: ObjectId

    let title: String
    let displayName: String
    let locationName: String
    let backgroundUrl: String?
    let pictureUrl: String?

    let topBadgeLabel: String?
    let topBadgeImage: UIImage?

    let leftBadgeLabel: String
    let leftBadgeImage: UIImage?
    let leftSegmentLabel: String

    let rightBadgeLabel: String
    let rightBadgeImage: UIImage?
    let rightSegmentLabel: String

    init(with user: User) {
        self.type = .user
        self.id = user.id

        self.title = ViewModelHelper.titleLabel(for: user.userName, country: user.country)
        self.displayName = user.displayName
        self.locationName = ViewModelHelper.locationLabel(for: user.city, state: user.state)
        self.backgroundUrl = user.profileBackgroundUrl
        self.pictureUrl = user.profilePictureUrl

        self.topBadgeLabel = nil
        self.topBadgeImage = nil

        self.leftBadgeImage = UIImage(named: "icn_race_small")
        self.leftSegmentLabel = "Races"
        if user.raceCount == 1 {
            self.leftBadgeLabel = "\(user.raceCount) Race"
        } else {
            self.leftBadgeLabel = "\(user.raceCount) Races"
        }

        self.rightBadgeImage = UIImage(named: "icn_chapter_small")
        self.rightSegmentLabel = "Chapters"
        if user.chapterCount == 1 {
            self.rightBadgeLabel = "\(user.chapterCount) Chapter"
        } else {
            self.rightBadgeLabel = "\(user.chapterCount) Chapters"
        }
    }

    init(with chapter: Chapter) {
        self.type = .chapter
        self.id = chapter.id

        self.title = chapter.name
        self.displayName = chapter.description.isEmpty ? chapter.name : chapter.description
        self.locationName = ViewModelHelper.locationLabel(for: chapter.city, state: chapter.state)
        self.pictureUrl = chapter.mainImageUrl
        self.backgroundUrl = chapter.backgroundUrl

        if let stringTier = chapter.tier, let tier = Int(stringTier) {
            let chapterTier = ChapterTier(rawValue: tier)
            self.topBadgeLabel = chapterTier?.title
            self.topBadgeImage = UIImage(named: "icn_badge")
        } else {
            self.topBadgeLabel = nil
            self.topBadgeImage = nil
        }

        self.leftBadgeImage = UIImage(named: "icn_race_small")
        self.leftSegmentLabel = "Races"
        if chapter.raceCount == 1 {
            self.leftBadgeLabel = "\(chapter.raceCount) Race"
        } else {
            self.leftBadgeLabel = "\(chapter.raceCount) Races"
        }

        self.rightBadgeImage = UIImage(named: "icn_chapter_small")
        self.rightSegmentLabel = "Members"
        if chapter.memberCount == 1 {
            self.rightBadgeLabel = "\(chapter.memberCount) Member"
        } else {
            self.rightBadgeLabel = "\(chapter.memberCount) Members"
        }
    }

    init(with aircraft: Aircraft) {
        self.type = .aircraft
        self.id = aircraft.id

        self.title = aircraft.name
        self.displayName = ""
        self.locationName = ""
        self.pictureUrl = aircraft.mainImageUrl
        self.backgroundUrl = aircraft.backgroundImageUrl

        self.topBadgeLabel = nil
        self.topBadgeImage = nil

        self.leftBadgeLabel = ""
        self.leftBadgeImage = nil
        self.leftSegmentLabel = ""

        self.rightBadgeLabel = ""
        self.rightBadgeImage = nil
        self.rightSegmentLabel = ""
    }
}

public enum ProfileViewModelType: String {
    case user = "user"
    case chapter = "chapter"
    case aircraft = "aircraft"

    var placeholder: UIImage? {
        switch self {
        case .user:         return PlaceholderImg.profileAvatar
        case .chapter:      return PlaceholderImg.profileAvatar
        case .aircraft:     return PlaceholderImg.profileAircraft
        }
    }
}
