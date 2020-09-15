//
//  SafariActivity.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-13.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit

class SafariActivity: UIActivity {

    override var activityTitle: String? {
        return "Open in Safari"
    }

    override var activityImage: UIImage? {
        return UIImage(named: "icn_activity_safari")
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        for item in activityItems {
            if let url = item as? URL {
                return UIApplication.shared.canOpenURL(url)
            }
        }

        return false
    }

    override func prepare(withActivityItems activityItems: [Any]) {
        for item in activityItems {
            if let url = item as? URL {
                _url = url
            }
        }
    }

    override func perform() {
        guard let url = _url else { return }

        UIApplication.shared.open(url , options: [:]) { [weak self] (completed) in
            self?.activityDidFinish(completed)
        }
    }

    fileprivate var _url : URL? = nil
}
