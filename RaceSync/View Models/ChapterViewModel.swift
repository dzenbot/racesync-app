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
    let joinState: JoinState

    init(with chapter: Chapter) {
        self.chapter = chapter
        self.titleLabel = chapter.name
        self.locationLabel = ChapterViewModel.locationLabel(for: chapter)
        self.imageUrl = ChapterViewModel.imageUrl(for: chapter)
        self.joinState = ChapterViewModel.joinState(for: chapter)
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

    static func joinState(for chapter: Chapter) -> JoinState {
        return chapter.isJoined ? .joined : .join
    }
}

extension Array where Element: ChapterViewModel {

    func chapter(withId id: ObjectId) -> Chapter? {
        let filteredModels = self.filter({ (viewModel) -> Bool in
            return viewModel.chapter.id == id
        })

        guard let viewModel = filteredModels.first else { return nil }
        return viewModel.chapter
    }
}
