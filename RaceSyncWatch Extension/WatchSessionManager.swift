//
//  WatchSessionManager.swift
//  RaceSyncWatch Extension
//
//  Created by Ignacio Romero Zurbuchen on 2020-12-25.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit
import WatchKit
import WatchConnectivity

protocol WatchSessionManagerDelegate {
    func sessionDidReceiveUserContext(_ userViewModel: UserViewModel)
}

class WatchSessionManager: NSObject {

    static let sharedManager = WatchSessionManager()

    fileprivate var delegates: [WatchSessionManagerDelegate] = [WatchSessionManagerDelegate]()
    fileprivate static let UserInfoKey = "com.multigp.RaceSyncApp.watchkitapp.userInfo"

    private override init() {
        super.init()
    }

    private let session: WCSession = WCSession.default

    func startSession() {
        session.delegate = self
        session.activate()
    }

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

    var storedUserInfo: [String : Any]? {
        get {
            return UserDefaults.standard.dictionary(forKey: WatchSessionManager.UserInfoKey)
        }
    }
}

extension WatchSessionManager: WCSessionDelegate {

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        //
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        print("didReceiveUserInfo \(userInfo)")
    }

    func session(_ session: WCSession, didReceiveApplicationContext userInfo: [String : Any]) {
        print("didReceiveApplicationContext!")

        guard let userViewModel = UserViewModel(userInfo) else { return }

        delegates.forEach { (delegate) in
            delegate.sessionDidReceiveUserContext(userViewModel)
        }

        UserDefaults.standard.setValue(userInfo, forKey: WatchSessionManager.UserInfoKey)
        UserDefaults.standard.synchronize()
    }
}
