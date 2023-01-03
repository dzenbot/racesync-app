//
//  RaceViewModel.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-19.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI
import CoreLocation

class RaceViewModel: Descriptable {

    let race: Race

    let titleLabel: String
    let dateLabel: String?
    let fullDateLabel: String?
    let locationLabel: String
    let fullLocationLabel: String
    let distanceLabel: String
    let distance: Double
    let joinState: JoinState
    let participantCount: Int
    let classLabel: String
    let chapterLabel: String
    let ownerLabel: String
    let seasonLabel: String
    let imageUrl: String?

    // MARK: - Initializatiom

    init(with race: Race) {
        self.race = race
        self.titleLabel = race.name
        self.dateLabel = Self.dateLabelString(for: race) // "Sat Sept 14 @ 9:00 AM"
        self.fullDateLabel = Self.fullDateLabelString(for: race) // "Saturday, September 14th @ 9:00 AM"
        self.locationLabel = Self.locationLabelString(for: race)
        self.fullLocationLabel = Self.fullLocationLabelString(for: race)
        self.distanceLabel = Self.distanceLabelString(for: race) // "309.4 mi" or "122 kms"
        self.distance = Self.distance(for: race)
        self.joinState = Self.joinState(for: race)
        self.participantCount = Int(race.participantCount) ?? 0

        if let raceClass = race.raceClass {
            self.classLabel = raceClass.title
        } else {
            self.classLabel = "" // show blank in case for older races
        }

        self.chapterLabel = race.chapterName
        self.ownerLabel = race.ownerUserName
        self.seasonLabel = race.seasonName
        self.imageUrl = Self.imageUrl(for: race)
    }

    static func viewModels(with objects:[Race]) -> [RaceViewModel] {
        var viewModels = [RaceViewModel]()
        for object in objects {
            viewModels.append(RaceViewModel(with: object))
        }
        return viewModels
    }

    static func sortedViewModels(with objects:[Race], sorting: RaceViewSorting = .ascending) -> [RaceViewModel] {
        let viewModels = Self.viewModels(with: objects)
        return viewModels.sorted(by: { (r1, r2) -> Bool in
            guard let date1 = r1.race.startDate, let date2 = r2.race.startDate else { return true }

            if sorting == .ascending {
                return date1 > date2
            } else if sorting == .descending {
                return date1 < date2
            } else if sorting == .distance {
                if r1.distance < r2.distance {
                    return true
                }
                if r1.distance == r2.distance {
                    guard let date1 = r1.race.startDate, let date2 = r2.race.startDate else { return true }
                    return date1 < date2
                }
                return false
            } else {
                return false
            }
        })
    }
}

enum RaceViewSorting {
    // ascending is oldest to most recent
    case ascending, descending, distance
}

extension RaceViewModel {

    static func dateLabelString(for race: Race) -> String? {
        guard let date = race.startDate else { return nil }
        return DateUtil.localizedString(from: date)
    }

    static func fullDateLabelString(for race: Race) -> String? {
        guard let date = race.startDate else { return nil }
        return DateUtil.localizedString(from: date, full: true)
    }

    static func locationLabelString(for race: Race) -> String {
        return ViewModelHelper.locationLabel(for: race.city, state: race.state, country: race.country)
    }

    static func fullLocationLabelString(for race: Race) -> String {
        var string = ""
        if let address = race.address, !address.isEmpty  {
            string += address + "\n"
        }
        string += ViewModelHelper.locationLabel(for: race.city, state: race.state, country: race.country)
        return string
    }

    static func imageUrl(for race: Race) -> String? {
        return ImageUtil.getImageUrl(for: race.chapterImageFileName)
    }

    static func joinState(for race: Race) -> JoinState {
        if race.status == .closed { return .closed }
        return race.isJoined ? .joined : .join
    }

    static func distance(for race: Race) -> Double {
        guard let raceLat = Double(race.latitude), let raceLong = Double(race.longitude) else { return 0 }
        guard let userlocation = userLocation() else { return 0 }

        let raceLocation = CLLocation(latitude: raceLat, longitude: raceLong)

        let distance = raceLocation.distance(from: userlocation)/1000
        let lengthUnit = APIServices.shared.settings.lengthUnit

        if lengthUnit == .miles {
            return APIUnitSystem.convert(distance, to: lengthUnit)
        } else {
            return distance
        }
    }

    static func distanceLabelString(for race: Race) -> String {
        let distance = Self.distance(for: race)

        let string = NumberUtil.string(for: distance)
        let lengthUnit = APIServices.shared.settings.lengthUnit

        return "\(string) \(lengthUnit.symbol)"
    }

    fileprivate static func userLocation() -> CLLocation? {
        guard let myUser = APIServices.shared.myUser else { return nil }

        if let location = LocationManager.shared.location {
            return location
        } else if let lat = Double(myUser.latitude), let long = Double(myUser.longitude) {
            return CLLocation(latitude: lat, longitude: long)
        } else {
            return nil
        }
    }
}

extension Array where Element: RaceViewModel {

    func race(withId id: ObjectId) -> Race? {
        let filteredModels = self.filter({ (viewModel) -> Bool in
            return viewModel.race.id == id
        })

        guard let viewModel = filteredModels.first else { return nil }
        return viewModel.race
    }
}
