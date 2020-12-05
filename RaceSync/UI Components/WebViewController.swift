//
//  WebViewController.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-05.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import SafariServices
import RaceSyncAPI

class WebViewController: SFSafariViewController {

    static func open(_ web: MGPWebConstant) {
        openUrl(web.rawValue)
    }

    static func openUrl(_ url: String) {
        guard let url = URL(string: url) else { return }

        let webvc = WebViewController(url: url)
        UIViewController.topMostViewController()?.present(webvc, animated: true, completion: nil)
    }

    // MARK: - Initialization

    init(url URL: URL) {
        super.init(url: URL, configuration: SFSafariViewController.Configuration())
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: - Layout

    func configureLayout() {
        preferredBarTintColor = Color.navigationBarColor
        preferredControlTintColor = Color.blue
        dismissButtonStyle = .close
    }

}
