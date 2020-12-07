//
//  UIColor+Extensions.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-10-30.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

import Foundation
import UIKit

extension UIColor {

    static func new(_ hex: String) -> UIColor {
        return UIColor.init(hex: hex)
    }

    convenience init(hex: String) {
        let hexString: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner: Scanner = Scanner(string: hexString)

        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }

        var color: UInt32 = 0
        scanner.scanHexInt32(&color)

        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask

        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0

        self.init(red:red, green:green, blue:blue, alpha:1)
    }

    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0

        return String(format:"#%06x", rgb)
    }

    static func randomColor(seed: String) -> UIColor {
        guard seed.count > 1 else { return .clear }
        
        var total: Int = 0
        for u in seed.unicodeScalars {
            total += Int(UInt32(u))
        }

        srand48(total * 300)
        let hue = CGFloat(drand48())

        return UIColor(hue: hue, saturation: 0.9, brightness: 0.8, alpha: 1)
    }
}
