//
//  CustomButton.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-11-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

class CustomButton: UIButton {

    var hitTestEdgeInsets: UIEdgeInsets = .zero

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {

        if hitTestEdgeInsets == .zero {
            return super.point(inside: point, with: event)
        } else {
            let hitFrame = bounds.inset(by: hitTestEdgeInsets)
            return hitFrame.contains(point)
        }
    }
}

