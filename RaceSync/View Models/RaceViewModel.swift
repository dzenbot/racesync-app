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
    let joinState: JoinState
    let participantCount: Int
    let imageUrl: String?

    // MARK: - Initializatiom

    init(with race: Race) {
        self.race = race
        self.titleLabel = race.name
        self.dateLabel = RaceViewModel.dateLabelString(for: race) // "Sat Sept 14 @ 9:00 AM"
        self.fullDateLabel = RaceViewModel.fullDateLabel(for: race) // "Saturday, September 14th @ 9:00 AM"
        self.locationLabel = RaceViewModel.locationLabel(for: race)
        self.fullLocationLabel = RaceViewModel.fullLocationLabel(for: race)
        self.distanceLabel = RaceViewModel.distanceString(for: race) // "309.4 mi"
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
        guard let date = DateUtil.deserializeJSONDate(race.startDate) else { return nil }
        return DateUtil.localizedString(from: date)
    }

    static func fullDateLabel(for race: Race) -> String? {
        guard let date = DateUtil.deserializeJSONDate(race.startDate) else { return nil }
        return DateUtil.localizedString(from: date, full: true)
    }

    static func locationLabel(for race: Race) -> String {
        return ViewModelHelper.locationLabel(for: race.city, state: race.state, country: race.country)
    }

    static func fullLocationLabel(for race: Race) -> String {
        var string = ""
        if let address = race.address {
            string += address + "\n"
        }
        string += ViewModelHelper.locationLabel(for: race.city, state: race.state, country: race.country)
        return string
    }

    static func imageUrl(for race: Race) -> String? {
        return ImageUtil.getSizedUrl(race.chapterImageFileName, size: CGSize(width: 50, height: 50))
    }

    static func joinState(for race: Race) -> JoinState {
        guard let status = RaceStatus(rawValue: race.status) else { return .join }
        if status == .closed { return .closed }
        return race.isJoined ? .joined : .join
    }

    static func distanceString(for race: Race) -> String {
        guard let myUser = APIServices.shared.myUser else { return "" }
        guard let userLat =  Double(myUser.latitude), let userLong = Double(myUser.longitude) else { return "" }
        guard let raceLat =  Double(race.latitude), let raceLong = Double(race.longitude) else { return "" }

        let raceLocation = CLLocation(latitude: raceLat, longitude: raceLong)
        let userLocation = CLLocation(latitude: userLat, longitude: userLong)

        let meters = raceLocation.distance(from: userLocation)
        let miles = NumberUtil.string(for: (meters/1609.344))

        return "\(miles) mi"
    }
}
