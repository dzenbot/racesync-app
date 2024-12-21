//
//  Clog.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-03-05.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import Foundation

public enum ClogLevel {
    case none, error, debug, verbose
}

public class Clog : NSObject {

    public class func log(_ message: String, andLevel level: ClogLevel = .debug) {
        print("+ \(message)")
    }
}
