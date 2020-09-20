//
//  CopyLinkActivity.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-09-20.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit

class CopyLinkActivity: UIActivity {

    override var activityTitle: String? {
        return "Copy Link"
    }

    override var activityImage: UIImage? {
        return UIImage(named: "icn_activity_copylink")
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

        UIPasteboard.general.string = url.absoluteString
        activityDidFinish(true)
    }

    fileprivate var _url : URL? = nil
}
