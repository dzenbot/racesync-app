//
//  MGPWebConstant.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-11.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation

public enum MGPWebConstant: String {
    case home = "https://www.multigp.com/"
    case apiBase = "https://www.multigp.com/mgp/multigpwebservice/"

    case passwordReset = "https://www.multigp.com/initiatepasswordreset"
    case accountRegistration = "https://www.multigp.com/register"
    case termsOfUse = "https://www.multigp.com/terms-of-use/"

    case raceView = "https://www.multigp.com/races/view/?race"
    case chapterView = "https://www.multigp.com/chapters/view/?chapter"
    case userView = "https://www.multigp.com/pilots/view/?pilot"
}

public class MGPWeb {

    public static func getURL(for constant: MGPWebConstant) -> URL {
        let url = getUrl(for: constant)
        return URL(string: url)!
    }

    public static func getUrl(for constant: MGPWebConstant) -> String {
        if ProcessInfo.processInfo.environment["api-environment"] == "dev" {
            return constant.rawValue.replacingOccurrences(of: "www", with: "test")
        } else {
            return constant.rawValue
        }
    }
}
