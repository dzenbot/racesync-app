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

public class APISessionManager {

    // MARK: - Session

    public static func hasValidSession() -> Bool {
        return getSessionId() != nil
    }
 
    public static func getSessionId() -> String? {
        return valet.string(forKey: sessionIdKey)
    }

    public static func invalidateSessionId() {
        setSessionId(nil)
    }

    public static func invalidateSession() {
        setSessionEmail(nil)
        setSessionPasword(nil)
        setSessionId(nil)
    }

    static func handleSessionJSON(_ json: JSON) {
        if let sessionId = json[ParamKey.sessionId].string {
            setSessionId(sessionId)
        }
    }

    // MARK: - Email

    public static func getSessionEmail() -> String? {
        return valet.string(forKey: sessionEmailKey)
    }

    static func setSessionEmail(_ email: String?) {
        if let email = email {
            valet.set(string: email, forKey: sessionEmailKey)
        } else {
            valet.removeObject(forKey: sessionEmailKey)
        }
    }

    // MARK: - Password

    public static func getSessionPasword() -> String? {
        return valet.string(forKey: sessionPwdKey)
    }

    static func setSessionPasword(_ pwd: String?) {
        if let pwd = pwd {
            valet.set(string: pwd, forKey: sessionPwdKey)
        } else {
            valet.removeObject(forKey: sessionPwdKey)
        }
    }

    // MARK: - Private

    fileprivate static func setSessionId(_ sessionId: String?) {
        if let sessionId = sessionId {
            valet.set(string: sessionId, forKey: sessionIdKey)
        } else {
            valet.removeObject(forKey: sessionIdKey)
        }
    }

    fileprivate static let valet = Valet.valet(with: Identifier(nonEmpty: "RaceSync")!, accessibility: .whenUnlocked)

    fileprivate static let sessionIdKey = "com.multigp.RaceSync.session.id"
    fileprivate static let sessionEmailKey = "com.multigp.RaceSync.session.email"
    fileprivate static let sessionPwdKey = "com.multigp.RaceSync.session.pwd"
}
