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
    public let credential = APICredential()
    public let settings = APISettings()

    public var myUser: User? {
        didSet {
            // Override useful for debugging a specific user's issue
            // myUser?.id = "8062"

            Clog.log("Did set my User with id: \(String(describing: myUser?.id))")
        }
    }

    public var myManagedChapters: [ManagedChapter]? {
        didSet {
            
        }
    }

    public var isLoggedIn: Bool {
        get { return APISessionManager.hasValidSession() }
    }

    // MARK: - Initialization

    public init() {
        NetworkActivityIndicatorManager.shared.isEnabled = true
    }
}
