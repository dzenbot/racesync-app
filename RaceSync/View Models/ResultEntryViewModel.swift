//
//  ResultEntryViewModel.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2024-12-19.
//  Copyright © 2024 MultiGP Inc. All rights reserved.
//

import RaceSyncAPI
import UIKit

class ResultEntryViewModel: Descriptable {

    let entry: ResultEntry
    let resultLabel: String

    init(with entry: ResultEntry, from race: Race) {
        self.entry = entry
        self.resultLabel = Self.resultLabel(for: entry, for: race)
    }
}

extension ResultEntryViewModel {

    static let noResultPlaceholder: String = "Did not complete laps"

    static func combinedResults(from entries: [ResultEntry]?, for scoringFormat: ScoringFormat) -> [ResultEntry]? {
        guard let entries = entries else { return nil }

        enum SortOrder {
            case lowest
            case highest
        }

        let formatMapping: [ScoringFormat: (key: KeyPath<ResultEntry, String?>, order: SortOrder)] = [
            .aggregateLap: (\.totalLaps, .highest),
            .fastestLap: (\.fastestLap, .lowest),
            .fastest2Laps: (\.fastest2Laps, .lowest),
            .fastest3Laps: (\.fastest3Laps, .lowest)
        ]

        guard let format = formatMapping[scoringFormat] else { return nil }

        let unique = entries.reduce(into: [ObjectId: ResultEntry]()) { dict, entry in
            guard let newValue = Double(entry[keyPath: format.key] ?? "") else { return }

            if let oldEntry = dict[entry.pilotId],
               let oldValue = Double(oldEntry[keyPath: format.key] ?? "") {
                if format.order == .lowest, oldValue < newValue { return }
                if format.order == .highest, oldValue > newValue { return }
            }

            dict[entry.pilotId] = entry
        }

        guard unique.count > 0 else { return nil }

        return unique.values.sorted {
            let value1 = Double($0[keyPath: format.key] ?? "") ?? .greatestFiniteMagnitude
            let value2 = Double($1[keyPath: format.key] ?? "") ?? .greatestFiniteMagnitude

            return format.order == .lowest ? value1 < value2 : value1 > value2
        }
    }

    static func rankLabel(for position: Int) -> String {
        if position == 1 {
            return "🥇"
        } else if position == 2 {
            return "🥈"
        } else if position == 3 {
            return "🥉"
        }
        return "\(position)"
    }
}

fileprivate extension ResultEntryViewModel {

    static func resultLabel(for entry: ResultEntry, for race: Race) -> String {

        let format = race.trueScoringFormat
        let placeholder: String = "Did not complete laps"
        var resultLabel: String = ""

        // Needs at least 1 lap
        print("lap count \(String(describing: Int(entry.totalLaps ?? "-1")))")
        
        guard let laps = Int(entry.totalLaps ?? "-1"), laps > 0 else {
            return placeholder
        }

        if format == .aggregateLap, let laps = entry.totalLaps {
            resultLabel += " \(laps) Laps"
        } else {
            var time: String?

            if format == .fastestLap {
                time = entry.fastestLap
            } else if format == .fastest2Laps {
                time = entry.fastest2Laps
            } else if format == .fastest3Laps {
                time = entry.fastest3Laps
            }

            if let time = time {
                resultLabel += TimeUtil.lapTimeFormat(seconds: time)
            }
        }

        if let roundLabel = Self.roundLabel(for: entry, for: race) {
            resultLabel += " \(roundLabel)"
        }

        return resultLabel.count > 0 ? resultLabel : placeholder
    }

    static func roundLabel(for raceEntry: ResultEntry, for race: Race) -> String? {
        guard let schedule = race.schedule else { return "" }
        for round in schedule.rounds {
            for heat in round.heats {
                if heat.entries.contains(where: { $0.id == raceEntry.id }) {
                    if let number = round.number {
                        return "(Best Round: \(number))"
                    }
                }
            }
        }
        return  nil
    }
}
