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
        self.locationLabel = Self.locationLabel(for: chapter)
        self.imageUrl = Self.imageUrl(for: chapter)
        self.joinState = Self.joinState(for: chapter)
    }

    static func viewModels(with objects:[Chapter]) -> [ChapterViewModel] {
        var viewModels = [ChapterViewModel]()
        for object in objects {
            viewModels.append(ChapterViewModel(with: object))
        }
        return viewModels
    }
}

extension ChapterViewModel {

    static func locationLabel(for chapter: Chapter) -> String {
        return ViewModelHelper.locationLabel(for: chapter.city, state: chapter.state)
    }

    static func imageUrl(for chapter: Chapter) -> String? {
        return ImageUtil.getImageUrl(for: chapter.mainImageUrl)
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
