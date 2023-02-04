//
//  Descriptable.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-20.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import Foundation

public protocol Descriptable {
    var attributesDescription: NSString { get }
}

// Outputs a list of all the attributes of the object confirming to Descriptable
extension Descriptable {

    public var attributesDescription: NSString {

        let mirror = Mirror(reflecting: self)
        var output: [String] = ["{"]

        for (_, attr) in mirror.children.enumerated() {
            if let property_name = attr.label {
                output.append("    - \(property_name) = \(attr.value)")
            }
        }

        output.append("}")

        return NSString(string: output.joined(separator: "\n"))
    }
}
