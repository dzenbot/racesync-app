//
//  RSAPIServices.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-10-27.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import AlamofireNetworkActivityIndicator

public class APIServices {

    // MARK: - Public Variables

    public static let shared = APIServices()
    public let environment: APIEnvironment

    public var myUser: User? {
        didSet {
            print("Did set my User with id: \(String(describing: myUser?.id))")
        }
    }

    public var isLoggedIn: Bool {
        get { return APISessionManager.hasValidSession() }
    }

    public static var isDev: Bool {
        return ProcessInfo.processInfo.environment["api-environment"] == "dev"
    }

    // MARK: - Initialization

    public init() {
        self.environment = APIEnvironment()

        NetworkActivityIndicatorManager.shared.isEnabled = true
    }
}
