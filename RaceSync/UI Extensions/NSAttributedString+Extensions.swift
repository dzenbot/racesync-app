//
//  NSAttributedString+Extensions.swift
//  RaceSync
//
//  Created by Ignacio Romero Zurbuchen on 2019-12-15.
//  Copyright © 2019 MultiGP Inc. All rights reserved.
//

import UIKit
import RaceSyncAPI

extension NSAttributedString {

    public convenience init?(string: String, font: UIFont? = nil, color: UIColor? = nil) {
        guard !string.isEmpty else { return nil }

        var attrs = [NSAttributedString.Key: Any]()
        attrs[NSAttributedString.Key.font] = font
        attrs[NSAttributedString.Key.foregroundColor] = color

        self.init(string: string, attributes: attrs)
    }

    public convenience init?(HTMLString content: String, font: UIFont? = nil, color: UIColor? = nil) throws {
        guard !content.isEmpty else { return nil }

        let maxWidth = UIScreen.main.bounds.width - UniversalConstants.padding*2
        let htmlString = content.toHTML(color)

        var options = [NSAttributedString.DocumentReadingOptionKey : Any]()
        options[.documentType] = NSAttributedString.DocumentType.html
        options[.characterEncoding] = String.Encoding.utf8.rawValue

        guard let data = htmlString.data(using: .utf8, allowLossyConversion: true) else {
            throw NSError(domain: "Parse Error", code: 0, userInfo: nil)
        }

        let att = try! NSAttributedString.init( data: data, options: options, documentAttributes: nil)
        let matt = NSMutableAttributedString(attributedString: att)

        func applyTraitsFromFont(_ f1: UIFont, to f2: UIFont) -> UIFont? {
            let t = f1.fontDescriptor.symbolicTraits
            if let fd = f2.fontDescriptor.withSymbolicTraits(t) {
                return UIFont.init(descriptor: fd, size: 0)
            }
            return nil
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

extension String {

    // Asynchrounsly parse HTML String into NSAttributedString
    public func toHTMLAttributedString(_ font: UIFont? = nil, color: UIColor? = nil, completion: @escaping SimpleObjectCompletionBlock<NSAttributedString?>) {
        guard !isEmpty else { completion(nil); return }

        let htmlString = toHTML(color)

        DispatchQueue.global(qos: .utility).async {
            var options = [NSAttributedString.DocumentReadingOptionKey : Any]()
            options[.documentType] = NSAttributedString.DocumentType.html
            options[.characterEncoding] = String.Encoding.utf8.rawValue

            guard let data = htmlString.data(using: .utf8, allowLossyConversion: true) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            guard let att = try? NSAttributedString.init( data: data, options: options, documentAttributes: nil) else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            let matt = NSMutableAttributedString(attributedString: att)

            func applyTraitsFromFont(_ f1: UIFont, to f2: UIFont) -> UIFont? {
                let t = f1.fontDescriptor.symbolicTraits
                if let fd = f2.fontDescriptor.withSymbolicTraits(t) {
                    return UIFont.init(descriptor: fd, size: 0)
                }
                return nil
            }

            if let newFont = font {
                matt.enumerateAttribute(NSAttributedString.Key.font, in: NSMakeRange(0, matt.length),
                                        options: .longestEffectiveRangeNotRequired) { value, range, stop in
                    let f1 = value as! UIFont
                    if let f3 = applyTraitsFromFont(f1, to: newFont) {
                        matt.addAttribute(NSAttributedString.Key.font, value:f3, range: range)
                    }
                }
            }

            DispatchQueue.main.async {
                completion(NSAttributedString.init(attributedString: matt))
            }
        }
    }

    public func toHTML(_ textColor: UIColor?) -> String {

        let maxWidth = UIScreen.main.bounds.width - UniversalConstants.padding*2
        let colorString: String = (textColor != nil) ? textColor!.toHexString() : Color.black.toHexString()

        let htmlString = """
        <head>
        <style type=\"text/css\">
        body { color: \(colorString); }
        img { max-height: 100%; max-width: \(maxWidth) !important; width: auto; height: auto; }
        a { color: \(Color.red.toHexString()); }
        </style>
        </head>
        <body> \(self) </body>
        </html>
        """

        return htmlString
    }
}
