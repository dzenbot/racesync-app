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
    let imageUrl: String?

    // MARK: - Initializatiom

    init(with race: Race) {
        self.race = race
        self.titleLabel = race.name
        self.dateLabel = RaceViewModel.dateLabelString(for: race) // "Sat Sept 14 @ 9:00 AM"
        self.fullDateLabel = RaceViewModel.fullDateLabelString(for: race) // "Saturday, September 14th @ 9:00 AM"
        self.locationLabel = RaceViewModel.locationLabelString(for: race)
        self.fullLocationLabel = RaceViewModel.fullLocationLabelString(for: race)
        self.distanceLabel = RaceViewModel.distanceLabelString(for: race) // "309.4 mi" or "122 kms"
        self.distance = RaceViewModel.distance(for: race)
        self.joinState = RaceViewModel.joinState(for: race)
        self.participantCount = Int(race.participantCount) ?? 0
        self.imageUrl = RaceViewModel.imageUrl(for: race)
    }

    static func viewModels(with races:[Race]) -> [RaceViewModel] {
        var viewModels = [RaceViewModel]()
        for race in races {
            viewModels.append(RaceViewModel(with: race))
        }
        return viewModels
    }
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
        return ImageUtil.getSizedUrl(race.chapterImageFileName, size: CGSize(width: 50, height: 50))
    }

    static func joinState(for race: Race) -> JoinState {
        if race.status == .closed { return .closed }
        return race.isJoined ? .joined : .join
    }

    static func distance(for race: Race) -> Double {
        guard let myUser = APIServices.shared.myUser else { return 0 }
        guard let userLat =  Double(myUser.latitude), let userLong = Double(myUser.longitude) else { return 0 }
        guard let raceLat =  Double(race.latitude), let raceLong = Double(race.longitude) else { return 0 }

        let raceLocation = CLLocation(latitude: raceLat, longitude: raceLong)
        let userLocation = CLLocation(latitude: userLat, longitude: userLong)

        let distance = raceLocation.distance(from: userLocation)/1000
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
