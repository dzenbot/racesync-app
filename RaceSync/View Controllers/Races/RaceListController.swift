//
//  RaceMainListController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-03-05.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI
import CoreLocation

enum RaceListType: Int, EnumTitle {
    case joined, nearby, series

    var title: String {
        switch self {
        case .joined:   return "Joined Races"
        case .nearby:   return "Nearby Races"
        case .series:   return "Global Qualifier"
        }
    }
}

class RaceMainListController {

    // MARK: - Public Variables

    var showPastSeries: Bool = false

    // MARK: - Private Variables

    fileprivate let raceApi = RaceApi()
    fileprivate var raceListType: [RaceListType]
    fileprivate var raceList = [RaceListType: [RaceViewModel]]()

    // MARK: - Initialization

    init(_ types: [RaceListType]) {
        raceListType = types
    }

    // MARK: - Actions

    func shouldShowShimmer(for listType: RaceListType) -> Bool {
        if listType == .series, showPastSeries, raceList[listType]?.count == 0 {
            return true
        }

        return raceList[listType] == nil
    }

    func raceViewModels(for listType: RaceListType, forceFetch: Bool = false, completion: @escaping ObjectCompletionBlock<[RaceViewModel]>) {
        switch listType {
        case .joined:
            getJoinedRaces(forceFetch, completion)
        case .nearby:
            getNearbydRaces(forceFetch, completion)
        case .series:
            getSeriesRaces(forceFetch, completion)
        }
    }
}

fileprivate extension RaceMainListController {

    func getJoinedRaces(_ forceFetch: Bool = false, _ completion: @escaping ObjectCompletionBlock<[RaceViewModel]>) {
        if let viewModels = raceList[.joined], !forceFetch {
            completion(viewModels, nil)
        }

        raceApi.getMyRaces(filters: [.joined, .upcoming]) { (races, error) in
            if let upcomingRaces = races?.filter({ (race) -> Bool in
                guard let startDate = race.startDate else { return false }
                return startDate.isInToday || startDate.timeIntervalSinceNow.sign == .plus
            }) {
                let viewModels = RaceViewModel.viewModels(with: upcomingRaces)
                let sortedViewModels = viewModels.sorted(by: { (r1, r2) -> Bool in
                    guard let date1 = r1.race.startDate, let date2 = r2.race.startDate else { return true }
                    return date1 < date2
                })

                self.raceList[.joined] = sortedViewModels
                completion(sortedViewModels, nil)
            } else {
                completion(nil, error)
            }
        }
    }

    func getNearbydRaces(_ forceFetch: Bool = false, _ completion: @escaping ObjectCompletionBlock<[RaceViewModel]>) {
        if let viewModels = raceList[.nearby], !forceFetch {
            completion(viewModels, nil)
        }

        let coordinate = LocationManager.shared.location?.coordinate
        let lat = coordinate?.latitude.string
        let long = coordinate?.longitude.string

        raceApi.getMyRaces(filters: [.nearby, .upcoming], latitude: lat, longitude: long) { (races, error) in
            if let upcomingRaces = races?.filter({ (race) -> Bool in
                guard let startDate = race.startDate else { return false }
                return startDate.isInToday || startDate.timeIntervalSinceNow.sign == .plus
            }) {
                let viewModels = RaceViewModel.viewModels(with: upcomingRaces)
                let sortedViewModels = viewModels.sorted(by: { (r1, r2) -> Bool in
                    if r1.distance < r2.distance {
                        return true
                    }
                    if r1.distance == r2.distance {
                        guard let date1 = r1.race.startDate, let date2 = r2.race.startDate else { return true }
                        return date1 < date2
                    }
                    return false
                })

                self.raceList[.nearby] = sortedViewModels
                completion(sortedViewModels, nil)
            } else {
                completion(nil, error)
            }
        }
    }

    func getSeriesRaces(_ forceFetch: Bool = false, _ completion: @escaping ObjectCompletionBlock<[RaceViewModel]>) {
        if let viewModels = raceList[.series], !forceFetch {
            completion(viewModels, nil)
        }

        var filters: [RaceListFilter] = [.series]
        if showPastSeries {
            filters = [.series, .past]
        }

        // One day, the API will support pagination
        // TODO: The race/list API should accept a year parameter, so only specific year's series races are returned
        raceApi.getRaces(filters: filters, pageSize: 150) { (races, error) in
            if let seriesRaces = races?.filter({ (race) -> Bool in
                guard let startDate = race.startDate else { return false }
                if self.showPastSeries {
                    return startDate.isInLastYear
                } else {
                    return startDate.isInThisYear
                }
            }) {
                let viewModels = RaceViewModel.viewModels(with: seriesRaces)
                let sortedViewModels = viewModels.sorted(by: { (r1, r2) -> Bool in
                    guard let date1 = r1.race.startDate, let date2 = r2.race.startDate else { return true }
                    return date1 > date2
                })

                self.raceList[.series] = sortedViewModels
                completion(sortedViewModels, nil)
            } else {
                completion(nil, error)
            }
        }
    }
}
