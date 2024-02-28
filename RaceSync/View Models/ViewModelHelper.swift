//
//  ViewModelHelper.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-20.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

class ViewModelHelper {

    static func titleLabel(for userName: String, country: String? = nil) -> String {
        var output = userName
        output.append(self.locationLabel(country: country))
        return output
    }

    static func locationLabel(for city: String? = nil, state: String? = nil, country: String? = nil) -> String {
        var strings = [String]()
        var output = String()

        if let city = city, !city.isEmpty {
            strings.append(city.capitalized)
        }
        if let state = state, !state.isEmpty {
            if state.count < 3 { // Acronyms
                strings.append(state.uppercased())
            } else {
                strings.append(state.capitalized)
            }
        }

        output = strings.joined(separator: strings.count > 1 ? ", " : "")

        // Use emojis for countries
        if let country = country, !country.isEmpty {
            output.append(" \(FlagEmojiGenerator.flag(country: country))")
        }

        return output
    }

}
