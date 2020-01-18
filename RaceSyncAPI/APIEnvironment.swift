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
    public let email: String?
    public let password: String?

    init() {
        apiKey = "3WlfklZkaSO7p8Y3qwxebeSEMllyLVyPST4cf4xqWmxmuwqU2Y9dc2SYnex9a5Y2Z3ff8MF48drCJRxLPHZ2KS186yihEgjDkyTslyxtLY6uQEgFlgI68JefiwwWNQA7"

        // Development tool for auto-completing the login screen
        #if DEBUG
            let bundle = Bundle(for: APIEnvironment.self)

            // TODO: Throw and print error
            if let path = bundle.path(forResource: "Credentials", ofType: "plist"),
                let dict = NSDictionary(contentsOfFile: path) {
                email = dict["EMAIL"] as? String
                password = dict["PASSWORD"] as? String
            } else {
                email = nil
                password = nil
            }
        #else
            email = nil
            password = nil
        #endif
    }
}
