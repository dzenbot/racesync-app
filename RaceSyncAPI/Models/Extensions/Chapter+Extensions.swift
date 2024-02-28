//
//  Chapter+Extensions.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2020-02-28.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation

public extension Chapter {

    var isMyChapter: Bool {
        guard let managedChapters = APIServices.shared.myManagedChapters else { return false }
        let chapterIds = managedChapters.compactMap { $0.id }
        return chapterIds.contains(id)
    }
}
