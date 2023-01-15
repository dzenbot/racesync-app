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

    // MARK: - Public Static Convenience Methods

    static func open(_ web: MGPWebConstant) {
        openUrl(web.rawValue)
    }

    static func openUrl(_ url: String) {
        guard let URL = URL(string: url) else { return }
        openURL(URL)
    }

    static func openURL(_ URL: URL) {
        let webvc = WebViewController(url: URL)
        UIViewController.topMostViewController()?.present(webvc, animated: true, completion: nil)
    }

    // MARK: - Initialization

    init(url URL: URL) {
        super.init(url: URL, configuration: Self.Configuration())
    }

    // MARK: - Lifecycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AppUtil.lockOrientation(.allButUpsideDown)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        AppUtil.lockOrientation(.portrait, andRotateTo: .portrait)

        super.dismiss(animated: flag, completion: completion)
    }

    // MARK: - Layout

    func configureLayout() {
        preferredBarTintColor = Color.navigationBarColor
        preferredControlTintColor = Color.blue
        dismissButtonStyle = .close
    }

}
