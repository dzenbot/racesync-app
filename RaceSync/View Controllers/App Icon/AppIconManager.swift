//
//  AppIconManager.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2021-08-23.
//  Copyright © 2021 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI
import UIKit

class AppIconManager {

    static func current() -> AppIcon {
      return AppIcon.allCases.first(where: {
        $0.name == UIApplication.shared.alternateIconName
      }) ?? .default
    }

    static func setIcon(_ appIcon: AppIcon, completion: ((Bool) -> Void)? = nil) {
        guard current() != appIcon, UIApplication.shared.supportsAlternateIcons else { return }

        UIApplication.shared.setAlternateIconName(appIcon.name) { error in
            if let error = error {
                print("Error setting alternate icon \(String(describing: appIcon.name)): \(error.localizedDescription)")
            }
            completion?(error != nil)
        }
    }
}

enum AppIcon: Int, CaseIterable, EnumTitle {
   case `default`, blue, white, io2022, kru

    var title: String {
        switch self {
        case .default:
            return "Red (Default)"
        case .blue:
            return "Blue"
        case .white:
            return "White"
        case .io2022:
            return "International Open 2022"
        case .kru:
            return "KwadsRUs (Vancouver, BC)"
        }
    }

    var preview: UIImage? {
        switch self {
        case .default:
            return UIImage(named: "AppIcon60x60") // Default app icon
        default:
            return UIImage(named: self.filename)
        }
    }

    fileprivate var name: String? {
        switch self {
        case .default:
            return nil
        case .blue:
            return "Blue"
        case .white:
            return "White"
        case .io2022:
            return "IO2022"
        case .kru:
            return "KRU"
        }
    }

    fileprivate var filename: String {
        switch self {
        case .default:
            return ""
        case .blue:
            return "AppIcon-Blue"
        case .white:
            return "AppIcon-White"
        case .io2022:
            return "AppIcon-IO2022"
        case .kru:
            return "AppIcon-KRU"
        }
    }
}
