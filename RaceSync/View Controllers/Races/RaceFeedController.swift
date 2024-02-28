//
//  RaceFeedController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-03-05.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI
import CoreLocation

enum RaceFilter: Int, EnumTitle {
    case joined, nearby, chapters, series

    var title: String {
        switch self {
        case .joined:           return "Joined"
        case .nearby:           return "Nearby"
        case .chapters:         return "Chapters"
        case .series:           return "GQ"
        }
    }
}

// 
class RaceFeedController {

    // MARK: - Public Variables

    var raceFilters: [RaceFilter]

    // MARK: - Private Variables

    fileprivate let raceApi = RaceApi()
    fileprivate var raceCollection = [RaceFilter: [RaceViewModel]]()

    fileprivate var settings: APISettings {
        get { return APIServices.shared.settings }
    }

    // MARK: - Initialization

    init(_ filters: [RaceFilter]) {
        self.raceFilters = filters
    }

    // MARK: - Actions

    func raceViewModelsCount(for filter: RaceFilter) -> Int {
        return raceCollection[filter]?.count ?? 0
    }

    func raceViewModels(for filter: RaceFilter) -> [RaceViewModel]? {
        return raceCollection[filter]
    }

    func shouldShowShimmer(for filter: RaceFilter) -> Bool {
        if filter == .series, raceCollection[filter]?.count == 0 {
            return true
        }
        return raceCollection[filter] == nil
    }

    func raceViewModels(for filter: RaceFilter, forceFetch: Bool = false, completion: @escaping ObjectCompletionBlock<[RaceViewModel]>) {
        switch filter {
        case .joined:
            getJoinedRaces(forceFetch, completion)
        case .nearby:
            getNearbydRaces(forceFetch, completion)
        case .chapters:
            getChapterRaces(forceFetch, completion)
        case .series:
            getSeriesRaces(forceFetch, completion)
        }
    }

    func invalidateDataSource() {
        raceCollection = [RaceFilter: [RaceViewModel]]() // re-initialize collection
    }
}

fileprivate extension RaceFeedController {

    func getJoinedRaces(_ forceFetch: Bool = false, _ completion: @escaping ObjectCompletionBlock<[RaceViewModel]>) {
        if let viewModels = raceCollection[.joined], !forceFetch {
            completion(viewModels, nil)
        }

        let filters = remoteFilters(with: .joined)
        let sorting: RaceViewSorting = settings.showPastEvents ? .ascending : .descending

        raceApi.getMyRaces(filters: filters) { [weak self] (races, error) in
            if let filteredRaces = self?.locallyFilteredRaces(races) {
                let sortedViewModels = RaceViewModel.sortedViewModels(with: filteredRaces, sorting: sorting)
                self?.raceCollection[.joined] = sortedViewModels
                completion(sortedViewModels, nil)
            } else {
                completion(nil, error)
            }
        }
    }

    func getNearbydRaces(_ forceFetch: Bool = false, _ completion: @escaping ObjectCompletionBlock<[RaceViewModel]>) {
        if let viewModels = raceCollection[.nearby], !forceFetch {
            completion(viewModels, nil)
        }

        let filters = remoteFilters(with: .nearby)

        let coordinate = LocationManager.shared.location?.coordinate
        let lat = coordinate?.latitude.string
        let long = coordinate?.longitude.string

        raceApi.getMyRaces(filters: filters, latitude: lat, longitude: long) { [weak self] (races, error) in
            if let filteredRaces = self?.locallyFilteredRaces(races) {
                let sortedViewModels = RaceViewModel.sortedViewModels(with: filteredRaces, sorting: .distance)
                self?.raceCollection[.nearby] = sortedViewModels
                completion(sortedViewModels, nil)
            } else {
                completion(nil, error)
            }
        }
    }

    func getChapterRaces(_ forceFetch: Bool = false, _ completion: @escaping ObjectCompletionBlock<[RaceViewModel]>) {
        guard let user = APIServices.shared.myUser else { return }

        if let viewModels = raceCollection[.chapters], !forceFetch {
            completion(viewModels, nil)
        }

        let filters = remoteFilters()
        let sorting: RaceViewSorting = settings.showPastEvents ? .ascending : .descending

        raceApi.getRaces(forChapters: user.chapterIds, filters: filters) { [weak self] races, error in
            if let filteredRaces = self?.locallyFilteredRaces(races) {
                let sortedViewModels = RaceViewModel.sortedViewModels(with: filteredRaces, sorting: sorting)
                self?.raceCollection[.chapters] = sortedViewModels
                completion(sortedViewModels, nil)
            } else {
                completion(nil, error)
            }
        }
    }

    func getSeriesRaces(_ forceFetch: Bool = false, _ completion: @escaping ObjectCompletionBlock<[RaceViewModel]>) {
        if let viewModels = raceCollection[.series], !forceFetch {
            completion(viewModels, nil)
        }

        var filters: [RaceListFilters] = [.series, .upcoming]

        // One day, the API will support pagination
        // TODO: The race/list API should accept a year parameter, so only specific year's series races are returned
        raceApi.getRaces(filters: filters, pageSize: 150) { (races, error) in
            if let seriesRaces = races?.filter({ (race) -> Bool in
                guard let startDate = race.startDate else { return false }
                return startDate.isInThisYear
            }) {
                let sortedViewModels = RaceViewModel.sortedViewModels(with: seriesRaces, sorting: .descending)
                self.raceCollection[.series] = sortedViewModels
                completion(sortedViewModels, nil)
            } else {
                completion(nil, error)
            }
        }
    }

    func locallyFilteredRaces(_ races: [Race]?) -> [Race]? {
        guard !settings.showPastEvents else { return races }

        return races?.filter({ (race) -> Bool in
            guard let startDate = race.startDate else { return false }
            return startDate.isInToday || startDate.timeIntervalSinceNow.sign == .plus
        })
    }

    func remoteFilters(with filter: RaceListFilters? = nil) -> [RaceListFilters] {
        var filters = [RaceListFilters]()

        if let filter = filter {
            filters += [filter]
        }
        if !settings.showPastEvents {
            filters += [.upcoming]
        }
        return filters
    }
}
