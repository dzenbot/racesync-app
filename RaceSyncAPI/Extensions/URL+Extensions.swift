//
//  URL+Extensions.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2020-03-04.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation

public extension URL {

    func appending(_ queryItem: String, value: String?) -> URL {
        guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }

        // Create array of existing query items
        var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []

        // Create query item
        let queryItem = URLQueryItem(name: queryItem, value: value)

        // Append the new query item in the existing query items array
        queryItems.append(queryItem)

        // Append updated query items array in the url component object
        urlComponents.queryItems = queryItems

        // Returns the url from new url components
        return urlComponents.url!
    }

    /// second-level domain [SLD]
    ///
    /// i.e. `msk.ru, spb.ru`
    var SLD: String? {
        return host?.components(separatedBy: ".").suffix(2).joined(separator: ".")
    }
}
