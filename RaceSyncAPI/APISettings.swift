//
//  APISettings.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-20.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation
import CoreGraphics

public class APISettings {

    public var searchRadius: CGFloat {
        get {
            let value = UserDefaults.standard.float(forKey: Self.settingsSearchRadiusKey)
            return CGFloat(value > 0 ? value : 500)
        } set {
            UserDefaults.standard.set(newValue, forKey: Self.settingsSearchRadiusKey)
        }
    }

    fileprivate static let settingsSearchRadiusKey = "com.multigp.RaceSync.settings.search_radius"
}
