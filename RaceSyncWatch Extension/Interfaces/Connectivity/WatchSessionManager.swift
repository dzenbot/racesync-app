//
//  WatchSessionManager.swift
//  RaceSyncWatch Extension
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-25.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import WatchKit
import WatchConnectivity

protocol WatchSessionManagerDelegate {
    func sessionDidReceiveUserContext(_ user: WatchUser)
    func sessionWasInvalidated()
}

class WatchSessionManager: NSObject {

    // MARK: - Public Variables

    static let shared = WatchSessionManager()

    var cachedUser: WatchUser? {
        guard let userInfo = cachedUserInfo else { return nil }
        return WatchUser(userInfo)
    }

    // MARK: - Private Variables

    fileprivate var delegates: [WatchSessionManagerDelegate] = [WatchSessionManagerDelegate]()

    // MARK: - Initialization

    override init() {
        super.init()
    }

    // MARK: - Life Cycle

    func startWatchConnection() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    func handleIncomingContext(_ userInfo: [String : Any]) {
        if let userViewModel = WatchUser(userInfo) {
            cacheUser(userInfo)

            delegates.forEach { (delegate) in
                delegate.sessionDidReceiveUserContext(userViewModel)
            }
        } else if let invalidate = userInfo[WParameterKey.invalidate] as? Bool, invalidate == true {
            invalidateCache()

            delegates.forEach { (delegate) in
                delegate.sessionWasInvalidated()
            }
        }
    }

    // MARK: - Delegates

    func add<T>(_ delegate: T) where T: WatchSessionManagerDelegate, T: Equatable {
        delegates.append(delegate)
    }

    func remove<T>(_ delegate: T) where T: WatchSessionManagerDelegate, T: Equatable {
        for (index, dataSourceDelegate) in delegates.enumerated() {
            if let dataSourceDelegate = dataSourceDelegate as? T, dataSourceDelegate == delegate {
                delegates.remove(at: index)
                break
            }
        }
    }

    // MARK: - Delegates

    fileprivate static let UserInfoKey = "com.multigp.RaceSyncApp.watchkitapp.userInfo"

    fileprivate var cachedUserInfo: [String : Any]? {
        get { return UserDefaults.standard.dictionary(forKey: WatchSessionManager.UserInfoKey) }
    }

    fileprivate func cacheUser(_ userInfo: [String : Any]) {
        UserDefaults.standard.setValue(userInfo, forKey: WatchSessionManager.UserInfoKey)
        UserDefaults.standard.synchronize()
    }

    fileprivate func invalidateCache() {
        UserDefaults.standard.setValue(nil, forKey: WatchSessionManager.UserInfoKey)
        UserDefaults.standard.synchronize()
    }
}

extension WatchSessionManager: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //
    }

    func session(_ session: WCSession, didReceiveApplicationContext userInfo: [String : Any]) {
        print("didReceiveApplicationContext!")

        DispatchQueue.main.async {
            self.handleIncomingContext(userInfo)
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        //
    }
}
