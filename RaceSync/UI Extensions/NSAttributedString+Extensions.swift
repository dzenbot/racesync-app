//
//  NSAttributedString+Extensions.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit

extension NSAttributedString {

    public convenience init?(HTMLString html: String, font: UIFont? = nil, color: UIColor? = nil) throws {
        guard !html.isEmpty else { return nil }

        let options : [NSAttributedString.DocumentReadingOptionKey: Any] =
            [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
             NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue]

        guard let data = html.data(using: .utf8, allowLossyConversion: true) else {
            throw NSError(domain: "Parse Error", code: 0, userInfo: nil)
        }

        func applyTraitsFromFont(_ f1: UIFont, to f2: UIFont) -> UIFont? {
            let t = f1.fontDescriptor.symbolicTraits
            if let fd = f2.fontDescriptor.withSymbolicTraits(t) {
                return UIFont.init(descriptor: fd, size: 0)
            }
            return nil
        }

        let att = try! NSAttributedString.init( data: data, options: options, documentAttributes: nil)
        let matt = NSMutableAttributedString(attributedString: att)

        if let newColor = color {
            var attrs = att.attributes(at: 0, effectiveRange: nil)
            attrs[NSAttributedString.Key.foregroundColor] = newColor
            matt.setAttributes(attrs, range: NSRange(location: 0, length: att.length))
        }

        if let newFont = font {
            matt.enumerateAttribute(NSAttributedString.Key.font, in:NSMakeRange(0,matt.length),
                                    options:.longestEffectiveRangeNotRequired) { value, range, stop in
                let f1 = value as! UIFont
                if let f3 = applyTraitsFromFont(f1, to: newFont) {
                    matt.addAttribute(NSAttributedString.Key.font, value:f3, range:range)
                }
            }
            self.init(attributedString: matt)
        }

        self.init(attributedString: matt)
    }
}
