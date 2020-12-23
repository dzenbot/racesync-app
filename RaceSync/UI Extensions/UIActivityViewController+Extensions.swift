//
//  UIActivityViewController+Extensions.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-09-20.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit

extension UIActivityViewController {

    func excludeAllActivityTypes(except activities: [UIActivity.ActivityType]) {
        let allActivities = UIActivity.ActivityType.AllCases

        let newlist = allActivities.filter({ (a) -> Bool in
            for b in activities {
                if a == b { return false }
                else { return true }
            }
            return false
        })

        excludedActivityTypes = newlist
    }

    func excludeAllActivityTypes() {
        excludedActivityTypes = UIActivity.ActivityType.AllCases
    }
}

extension UIActivity.ActivityType {
    static let AllCases: [UIActivity.ActivityType] = [
        .postToFacebook,
        .postToTwitter,
        .postToWeibo,
        .message,
        .mail,
        .print,
        .copyToPasteboard,
        .assignToContact,
        .saveToCameraRoll,
        .addToReadingList,
        .postToFlickr,
        .postToVimeo,
        .postToTencentWeibo,
        .airDrop,
        .openInIBooks,
        .markupAsPDF,
        .addToReadingList,
        .assignToContact
    ]
}
