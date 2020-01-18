//
//  RSAPIKey.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-10-27.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation

public class APIEnvironment {
    public let apiKey: String
    public let username: String?
    public let password: String?

    init() {
        let bundle = Bundle(for: APIEnvironment.self)

        // TODO: Throw and print error
        let path = bundle.path(forResource: "Credentials", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!)

        // TODO: Throw and print error
        apiKey = dict!["API_KEY"] as! String
        username = dict!["USERNAME"] as? String
        password = dict!["PASSWORD"] as? String
    }
}
