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
   case `default`, blue, white, kru, ottfpv, s3

    var title: String {
        switch self {
        case .default:
            return "Red (Default)"
        case .blue:
            return "Blue"
        case .white:
            return "White"
        case .kru:
            return "KwadsRUs Racing Club"
        case .ottfpv:
            return "Ottawa FPV Riders"
        case .s3:
            return "Safety Third Racing"
        }
    }

    var preview: UIImage? {
        switch self {
        case .default:
            return UIImage(named: "AppIcon60x60") // Default app icon
        default:
            return UIImage(named: filename)
        }
    }

    var name: String? {
        switch self {
        case .default:
            return nil
        case .blue:
            return "Blue"
        case .white:
            return "White"
        case .kru:
            return "KRU"
        case .ottfpv:
            return "OTTFPV"
        case .s3:
            return "S3"
        }
    }

    fileprivate var filename: String {
        let name = "AppIcon-\(name!)"
        return name
    }
}
