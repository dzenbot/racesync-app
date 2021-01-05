//
//  APISettings.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-20.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation

public protocol APISettingsDelegate {
    func didUpdate(settings: APISettingsType, with value: Any)
}

public enum APISettingsType: Int, EnumTitle {
    case searchRadius, measurement, environment

    public var title: String {
        switch self {
        case .searchRadius:     return "Search Radius"
        case .measurement:      return "Measurement System"
        case .environment:      return "Environment"
        }
    }

    var key: String {
        switch self {
        case .searchRadius:     return "com.multigp.RaceSync.settings.search_radius"
        case .measurement:      return "com.multigp.RaceSync.settings.measurement_system"
        case .environment:      return "com.multigp.RaceSync.settings.environment"
        }
    }
}

public class APISettings {

    // MARK: - Settings Setters / Getters

    public var searchRadius: String {
        get {
            return string(for: .searchRadius) ?? self.lengthUnit.defaultValue
        } set {
            save(newValue, type: .searchRadius)
        }
    }

    /// Similar to setting searchRadius, except this won't broadcast to delegate. To be used when updating searchRadius, and avoid broadcasting for the same change event.
    public func update(searchRadius: String) {
        save(searchRadius, type: .searchRadius, broadcast: false)
    }

    public var measurementSystem: APIMeasurementSystem {
        get {
            let value = int(for: .measurement)
            return APIMeasurementSystem(rawValue: value) ?? .imperial
        } set {
            save(newValue.rawValue, type: .measurement)
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
            if let rawValue = value(for: .environment) as? Int {
                if let env = APIEnvironment(rawValue: rawValue) { return env }
            }

            let dev = ProcessInfo.processInfo.environment["api-environment"] == "dev"
            return dev ? APIEnvironment.dev : APIEnvironment.prod
        } set {
            guard newValue != environment else { return }
            save(newValue.rawValue, type: .environment)
        }
    }

    // MARK: - Invalidation

    public func invalidateSettings() {

        let settingsKeys = UserDefaults.standard.dictionaryRepresentation().keys.filter { (key) -> Bool in
            return key.hasPrefix("com.multigp.RaceSync.settings")
        }

        for key in settingsKeys {
            UserDefaults.standard.set(nil, forKey: key)
        }

        UserDefaults.standard.synchronize()
    }

    // MARK: - Delegates

    public func add<T>(_ delegate: T) where T: APISettingsDelegate, T: Equatable {
        delegates.append(delegate)
    }

    public func remove<T>(_ delegate: T) where T: APISettingsDelegate, T: Equatable {
        for (index, aDelegate) in delegates.enumerated() {
            if let aDelegate = aDelegate as? T, aDelegate == delegate {
                delegates.remove(at: index)
                break
            }
        }
    }

    // MARK: - Private Variables

    fileprivate var delegates = [APISettingsDelegate]()
}

fileprivate extension APISettings {

    func save(_ value: Any, type: APISettingsType, broadcast: Bool = true) {
        UserDefaults.standard.set(value, forKey: type.key)

        Clog.log("Updating Setting \(type.key) with \(value)")

        guard broadcast else { return }
        DispatchQueue.main.async {
            self.delegates.forEach { (delegate) in
                delegate.didUpdate(settings: type, with: value)
            }
        }
    }

    func value(for type: APISettingsType) -> Any? {
        return UserDefaults.standard.object(forKey: type.key)
    }

    func int(for type: APISettingsType) -> Int {
        return UserDefaults.standard.integer(forKey: type.key)
    }

    func string(for type: APISettingsType) -> String? {
        return UserDefaults.standard.string(forKey: type.key)
    }
}
