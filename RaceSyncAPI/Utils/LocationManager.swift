//
//  LocationManager.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2020-03-07.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import CoreLocation

public class LocationManager: CLLocationManager {

    // MARK: - Public Variables

    public static let shared = LocationManager()

    public var authorizationStatus: CLAuthorizationStatus {
        get { return CLLocationManager.authorizationStatus() }
    }

    public var didRequestAuthorization: Bool {
        get { return authorizationStatus != .notDetermined }
    }

    // MARK: - Private Variables

    fileprivate var authorizationBlock: CompletionBlock?

    // MARK: - Initialization

    override init() {
        super.init()
        self.delegate = self
    }

    // MARK: - Public Functions

    public func requestsAuthorization(_ completion: CompletionBlock?) {
        let authorization = CLLocationManager.authorizationStatus()
        if authorization == .notDetermined {
            requestWhenInUseAuthorization()
            self.authorizationBlock = completion
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {

    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        Clog.log("Location Authorization changed to \(status)")

        if status == .authorizedWhenInUse {
            startUpdatingLocation()
        }
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            Clog.log("User Location updated \(location.coordinate)")

            authorizationBlock?(nil)
            authorizationBlock = nil
        }
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Clog.log("Location Failed with error: \(error.localizedDescription)", andLevel: .error)

        authorizationBlock?(error as NSError)
        authorizationBlock = nil
    }
}
