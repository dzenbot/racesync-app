//
//  ChapterViewModel.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-21.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI

class ChapterViewModel: Descriptable {

    let chapter: Chapter
    
    let titleLabel: String
    let locationLabel: String
    let imageUrl: String?

    init(with chapter: Chapter) {
        self.chapter = chapter
        self.titleLabel = chapter.name
        self.locationLabel = ChapterViewModel.locationLabel(for: chapter)
        self.imageUrl = ChapterViewModel.imageUrl(for: chapter)
    }

    static func viewModels(with chapters:[Chapter]) -> [ChapterViewModel] {
        var viewModels = [ChapterViewModel]()
        for chapter in chapters {
            viewModels.append(ChapterViewModel(with: chapter))
        }
        return viewModels
    }
}

extension ChapterViewModel {

    static func locationLabel(for chapter: Chapter) -> String {
        return ViewModelHelper.locationLabel(for: chapter.city, state: chapter.state)
    }

    static func imageUrl(for chapter: Chapter) -> String? {
        return ImageUtil.getSizedUrl(chapter.mainImageUrl, size: CGSize(width: 50, height: 50))
    }
}
