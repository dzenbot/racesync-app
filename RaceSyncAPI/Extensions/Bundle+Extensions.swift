//
//  Bundle+Extensions.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-21.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation

public extension Bundle {

    var applicationName: String {
        return infoDictionary!["CFBundleName"] as! String
    }

    var releaseVersionNumber: String {
        return infoDictionary!["CFBundleShortVersionString"] as! String
    }

    var buildVersionNumber: String {
        return infoDictionary!["CFBundleVersion"] as! String
    }

    var releaseDescriptionPretty: String {
        return "v\(releaseVersionNumber) (build #\(buildVersionNumber))"
    }
}
