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
}

// MARK: - WatchOS Connectivity Integration

extension ApplicationControl {

    func startWatchConnection() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    // MARK: - Private Methods

    fileprivate func sendUserDataToWatch() {
        guard let user = APIServices.shared.myUser, let qrImg = getQRImage(with: user.id) else { return }

        // If the dictionary doesn't change, subsequent calls to updateApplicationContext won't trigger
        // a corresponding call to didReceiveApplicationContext. Passing a unique Date() helps forcing an update.
        var userInfo: [String: Any] = [
            "id": user.id,
            "name": user.userName,
            "qr-data" : qrImg.jpegData(compressionQuality: 0.7)!,
            "force_send" : Date()
        ]

        if let userProfileUrl = APIServices.shared.myUser?.miniProfilePictureUrl,
           let img = ImageNetworking.cachedImage(for: userProfileUrl)?.rounded(Color.yellow) {
            userInfo["avatar-data"] = img.jpegData(compressionQuality: 0.7)!
        }

        do {
            try WCSession.default.updateApplicationContext(userInfo)
        }  catch {
            Clog.log("could not update context: \(error.localizedDescription)")
        }
    }

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
        if activationState == .activated, WCSession.default.isWatchAppInstalled {
            DispatchQueue.main.async {
                self.sendUserDataToWatch()
            }
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        //
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        //
    }

    func sessionDidDeactivate(_ session: WCSession) {
        //
    }
}
