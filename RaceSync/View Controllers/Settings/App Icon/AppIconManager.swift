//
//  AppIconManager.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2021-08-23.
//  Copyright © 2021 MultiGP Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import RaceSyncAPI

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

extension AppIcon {

    func isSelected() -> Bool {
        return name == AppIconManager.selectedIcon().name
    }
}

class AppIconLoader {

    static func loadAppIcons() -> [AppIcon] {
        guard let json = loadIconsJSON() else { return [AppIcon]() }
        return parseIconsJSON(json: json)
    }

    fileprivate static func loadIconsJSON() -> JSON? {
        guard let path = Bundle.main.path(forResource: "icons-list", ofType: "json") else { return nil }
        guard let jsonString = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else { return nil }
        return JSON(parseJSON: jsonString)
    }

    fileprivate static func parseIconsJSON(json: JSON) -> [AppIcon] {
        var icons = [AppIcon]()
        guard let array = json.arrayObject else { return icons }

        for object in array {
            guard let dict = object as? [String: Any] else { break }
            do {
                let icon = try AppIcon.init(JSON: dict)
                icons += [icon]
            }  catch {
                Clog.log("error parsing icon objects: \(error.localizedDescription)")
            }
        }
        return icons
    }
}
