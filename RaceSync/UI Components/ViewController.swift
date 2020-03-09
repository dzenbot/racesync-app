//
//  ViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-03-09.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var viewName: String?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        trackScreenChange()
    }

    func trackScreenChange() {
        if let name = viewName {
            EventCatcher.trackScreenView(withName: name)
        } else if let name = title {
            EventCatcher.trackScreenView(withName: name)
        }
    }
}
