//
//  UIEdgeInsets+Extensions.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2020-01-10.
//  Copyright © 2020 MultiGP Inc. All rights reserved.
//

import UIKit

extension UIEdgeInsets {

    public init(proportionally value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }

    public init(_ top: CGFloat, _ left: CGFloat, _ bottom: CGFloat, _ right: CGFloat) {
        self.init(top: top, left: left, bottom: bottom, right: right)
    }

    public init(top: CGFloat) {
        self.init(top: top, left: 0, bottom: 0, right: 0)
    }

    public init(left: CGFloat) {
        self.init(top: 0, left: left, bottom: 0, right: 0)
    }

    public init(bottom: CGFloat) {
        self.init(top: 0, left: 0, bottom: bottom, right: 0)
    }

    public init(right: CGFloat) {
        self.init(top: 0, left: 0, bottom: 0, right: right)
    }
}
