//
//  APISessionManager.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-28.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import SwiftyJSON

class APISessionManager {

    static func retrieveSessionId() -> String? {
        return getSessionId()
    }

    @discardableResult
    static func handleSessionJSON(_ json: JSON) -> Bool {
        if let sessionId = json[ParameterKey.sessionId].string {
            return setSessionId(sessionId)
        } else {
            return false
        }
    }

    @discardableResult
    static func handleSessionId(_ sessionId: String?) -> Bool {
        return setSessionId(sessionId)
    }

    @discardableResult
    static func invalidateSession() -> Bool {
        return setSessionId(nil)
    }
}

fileprivate extension APISessionManager {

    static let SessionIdKey = "com.multigp.RaceSync.session.id"

    static func getSessionId() -> String? {
        return UserDefaults.standard.object(forKey: SessionIdKey) as? String
    }

    static func setSessionId(_ sessionId: String?) -> Bool {
        UserDefaults.standard.set(sessionId, forKey: SessionIdKey)

        if UserDefaults.standard.synchronize() {
            if let id = sessionId {
                print("Did update user session \(id)")
            } else {
                print("Did invalidate session id")
            }
            return true
        } else {
            return false
        }
    }
}
