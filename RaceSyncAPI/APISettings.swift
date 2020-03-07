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
            return UserDefaults.standard.string(forKey: APISettingsSearchRadiusKey) ?? self.lengthUnit.defaultValue
        } set {
            save(newValue, key: APISettingsSearchRadiusKey)
        }
    }

    public var measurementSystem: APIMeasurementSystem {
        get {
            let value = UserDefaults.standard.integer(forKey: APISettingsMeasurementSystemKey)
            return APIMeasurementSystem(rawValue: value) ?? .imperial
        } set {
            save(newValue.rawValue, key: APISettingsMeasurementSystemKey)
        }
    }

    public var lengthUnit: APIUnitSystem {
        get {
            return (measurementSystem == .imperial) ? .miles : .kilometers
        }
    }

    public var isDev: Bool {
        return environment == .dev
    }

    public var environment: APIEnvironment {
        get {
            if let rawValue = UserDefaults.standard.object(forKey: APISettingsEnvironmentsKey) as? Int {
                if let env = APIEnvironment(rawValue: rawValue) { return env }
            }

            let dev = ProcessInfo.processInfo.environment["api-environment"] == "dev"
            return dev ? APIEnvironment.dev : APIEnvironment.prod
        } set {
            guard newValue != environment else { return }
            save(newValue.rawValue, key: APISettingsEnvironmentsKey)
        }
    }
}

fileprivate extension APISettings {

    func save(_ value: Any, key: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()

        Clog.log("Updating Setting \(key) with \(value)")
    }
}

fileprivate let APISettingsEnvironmentsKey = "com.multigp.RaceSync.settings.environment"
fileprivate let APISettingsSearchRadiusKey = "com.multigp.RaceSync.settings.search_radius"
fileprivate let APISettingsMeasurementSystemKey = "com.multigp.RaceSync.settings.measurement_system"
