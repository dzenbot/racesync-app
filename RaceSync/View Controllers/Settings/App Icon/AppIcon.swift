//
//  AppIcon.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2022-12-11.
//  Copyright © 2022 MultiGP Inc. All rights reserved.
//

import Foundation
import RaceSyncAPI
import ObjectMapper
import SwiftyJSON
import UIKit

class AppIcon: ImmutableMappable, Descriptable {

    let title: String
    let type: Int
    let name: String?
    let filename: String?
    let preview: UIImage?

    // MARK: - Initializatiom

    required init(map: Map) throws {
        title = try map.value("title")
        type = try map.value("type")
        name = try map.value("name")

        if let name = name {
            filename = "AppIcon-\(name)"
            preview = UIImage(named: filename!)
        } else {
            filename = nil
            preview = UIImage(named: "AppIcon60x60")
        }
    }

    init() {
        title = "Red (Default)"
        type = 1
        name = ""
        filename = nil
        preview = UIImage(named: "AppIcon60x60")
    }


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
            if let icon = AppIcon.init(JSON: dict) {
                icons += [icon]
            }
        }
        return icons
    }
}
