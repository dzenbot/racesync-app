//
//  ApplicationControl.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-20.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI

class ApplicationControl {

    static let shared = ApplicationControl()

    fileprivate let authApi = AuthApi()

    func invalidateSession() {
        guard let window = UIApplication.shared.delegate?.window else { return }

        APISessionManager.invalidateSession()
        APIServices.shared.invalidate()
        CrashCatcher.invalidateUser()

        // dismisses the presented view and displays the login screen view instead
        let rootViewController = window?.rootViewController
        rootViewController?.dismiss(animated: true)
    }

    func logout(switchTo environment: APIEnvironment = .prod) {
        authApi.logout { [weak self] (status, error) in
            if error == nil {
                self?.invalidateSession()
            }

            if status {
                APIServices.shared.settings.environment = environment
            }
        }
    }
}
