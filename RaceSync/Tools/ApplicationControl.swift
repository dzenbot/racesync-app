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

    func invalidateSession(forced: Bool = false) {
        guard let window = UIApplication.shared.delegate?.window else { return }

        if forced {
            APISessionManager.invalidateSession()
        } else {
            APISessionManager.invalidateSessionId() // doesn't remove email & pwd
        }

        APIServices.shared.invalidate()
        CrashCatcher.invalidateUser()
        invalidateWatchSession()

        // dismisses the presented view and displays the login screen view instead
        let rootViewController = window?.rootViewController
        rootViewController?.dismiss(animated: true)
    }

    // Default environment value is based on the existing environment
    func logout(switchTo environment: APIEnvironment = APIServices.shared.settings.environment, forced: Bool = false) {
        authApi.logout { [weak self] (status, error) in
            if error == nil {
                self?.invalidateSession(forced: forced)
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

        if WCSession.default.activationState != .activated {
            WCSession.default.delegate = self
            WCSession.default.activate()
        } else {
            sendUserDataToWatch() // assume we're just re-starting the connection, but still need to update the Watch
        }
    }

    func invalidateWatchSession() {
        let userInfo: [String: Any] = [
            WParamKey.invalidate: true,
            WParamKey.forceSend : Date()
        ]

        sendUserInfoToWatch(userInfo)
    }

    // MARK: - Private Methods

    fileprivate func sendUserDataToWatch() {
        guard let user = APIServices.shared.myUser, let qrImg = getQRImage(with: user.id) else { return }

        // If the dictionary doesn't change, subsequent calls to updateApplicationContext won't trigger
        // a corresponding call to didReceiveApplicationContext. Passing a unique Date() helps forcing an update.
        var userInfo: [String: Any] = [
            WParamKey.id: user.id,
            WParamKey.name: user.userName,
            WParamKey.qrData: qrImg.jpegData(compressionQuality: 0.7)!,
            WParamKey.forceSend: Date()
        ]

        // Use emojis for countries
        if let country = user.country, !country.isEmpty {
            userInfo[WParamKey.name] = "\(user.userName) \(FlagEmojiGenerator.flag(country: country))"
        }

        if let userProfileUrl = APIServices.shared.myUser?.miniProfilePictureUrl,
           let img = ImageNetworking.cachedImage(for: userProfileUrl)?.circular(with: Color.black) {
            userInfo[WParamKey.avatarData] = img.jpegData(compressionQuality: 0.7)!
        }

        sendUserInfoToWatch(userInfo)
    }

    fileprivate func sendUserInfoToWatch(_ userInfo: [String: Any]) {
        do {
            try WCSession.default.updateApplicationContext(userInfo)
        }  catch {
            Clog.log("WCSession: could not update context with error \(error.localizedDescription)")
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
            DispatchQueue.main.async { // these delegate methods are not thread safe
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
