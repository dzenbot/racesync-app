//
//  APISessionManager.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-28.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation
import SwiftyJSON
import Valet

class APISessionManager {

    fileprivate static let sessionIdKey = "com.multigp.RaceSync.session.id"
    fileprivate static let valet = Valet.valet(with: Identifier(nonEmpty: "RaceSync")!, accessibility: .whenUnlocked)

    static func hasValidSession() -> Bool {
        return getSessionId() != nil
    }

    static func getSessionId() -> String? {
        return valet.string(forKey: sessionIdKey)
    }

    static func handleSessionJSON(_ json: JSON) {
        if let sessionId = json[ParameterKey.sessionId].string {
            setSessionId(sessionId)
        }
    }

    static func setSessionId(_ sessionId: String?) {
        if let sessionId = sessionId {
            valet.set(string: sessionId, forKey: sessionIdKey)
        } else {
            valet.removeObject(forKey: sessionIdKey)
        }
    }

    static func invalidateSession() {
        setSessionId(nil)
    }
}
