//
//  ApplicationControl.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-20.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI
import WatchConnectivity
import QRCode

class ApplicationControl: NSObject {

    // MARK: - Public Variables

    static let shared = ApplicationControl()

    // MARK: - Private Variables

    fileprivate let authApi = AuthApi()
    fileprivate var avatarImage: UIImage? = nil

    // MARK: - Public Methods

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

    func saveWatchQRImage(with userImage: UIImage?) {
        guard WCSession.isSupported() else { return }

        self.avatarImage = userImage

        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - Private Methods

    fileprivate func getQRImage(with userId: String) -> UIImage? {
        var qrCode = QRCode(userId)
        qrCode?.size = CGSize(width: 100, height: 100)
        qrCode?.color = CIColor(color: Color.black)
        qrCode?.backgroundColor = CIColor(color: Color.white)
        return qrCode?.image
    }
}

extension ApplicationControl: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {

        if activationState == .activated, let user = APIServices.shared.myUser {
            guard let qrImg = getQRImage(with: user.id), let qrData = qrImg.jpegData(compressionQuality: 0.7) else { return }

            var userInfo: [String: Any] = [
                "id": user.id,
                "name": user.userName,
                "qr-data" : qrData,
                "force_send" : UUID().uuidString
            ]

            if let avatarImg = avatarImage, let avatarData = avatarImg.jpegData(compressionQuality: 0.7) {
                userInfo["avatar-data"] = avatarData
            }

            do {
                try WCSession.default.updateApplicationContext(userInfo)
            }  catch {
                Clog.log("could not update context: \(error.localizedDescription)")
            }
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        //
    }

    func sessionDidDeactivate(_ session: WCSession) {
        //
    }
}
