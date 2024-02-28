//
//  Clog.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-03-05.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation
import Sentry

public enum ClogLevel {
    case none, error, debug, verbose
}

public class Clog : NSObject {

    public class func log(_ message: String, andLevel level: ClogLevel = .debug) {




        //SentryLog.log(withMessage: "+ \(message)", andLevel: level.sentryLog)

        print("+ \(message)")
    }
}

fileprivate extension ClogLevel {
    var sentryLog: SentryLogLevel {
        switch self {
        case .none:     return SentryLogLevel.none
        case .error:     return SentryLogLevel.error
        case .debug:     return SentryLogLevel.debug
        case .verbose:     return SentryLogLevel.verbose
        }
    }
}
