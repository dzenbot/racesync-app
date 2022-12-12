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

    static let icons: [AppIcon] = AppIconLoader.loadAppIcons()

    static func selectedIcon() -> AppIcon {
      return icons.first(where: {
        $0.name == UIApplication.shared.alternateIconName
      }) ?? AppIcon()
    }

    static func selectIcon(_ icon: AppIcon, completion: ((Bool) -> Void)? = nil) {
        guard UIApplication.shared.supportsAlternateIcons else { return }

        UIApplication.shared.setAlternateIconName(icon.name) { error in
            if let error = error {
                print("Error setting alternate icon \(String(describing: icon.name)): \(error.localizedDescription)")
            }
            completion?(error != nil)
        }
    }
}
