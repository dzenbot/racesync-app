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

    public var searchRadius: String {
        get {
            guard let value = UserDefaults.standard.string(forKey: Self.settingsSearchRadiusKey) else { return DefaultSearchRadius }
            return value
        } set {
            UserDefaults.standard.set(newValue, forKey: Self.settingsSearchRadiusKey)
            UserDefaults.standard.synchronize()
        }
    }

    public var isDev: Bool {
        return environment == .dev
    }

    public var environment: APIEnvironment {
        get {
            if let rawValue = UserDefaults.standard.object(forKey: Self.settingsEnvironmentsKey) as? Int {
                if let env = APIEnvironment(rawValue: rawValue) { return env }
            }

            let dev = ProcessInfo.processInfo.environment["api-environment"] == "dev"
            return dev ? APIEnvironment.dev : APIEnvironment.prod
        } set {
            guard newValue != environment else { return }
            UserDefaults.standard.set(newValue.rawValue, forKey: Self.settingsEnvironmentsKey)
            UserDefaults.standard.synchronize()
        }
    }

    fileprivate static let settingsSearchRadiusKey = "com.multigp.RaceSync.settings.search_radius"
    fileprivate static let settingsEnvironmentsKey = "com.multigp.RaceSync.settings.environment"
}
