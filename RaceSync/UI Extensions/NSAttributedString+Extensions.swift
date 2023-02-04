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

public extension String {

    // Asynchrounsly parse HTML String into NSAttributedString
    func toHTMLAttributedString(_ font: UIFont? = nil, color: UIColor? = nil, completion: @escaping SimpleObjectCompletionBlock<NSAttributedString?>) {
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

    func toHTML(_ textColor: UIColor?) -> String {

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

    func stripHTML(_ removeLineBreaks: Bool = false) -> String {
        var str = self.stringByDecodingHTMLEntities
        str = str.replacingOccurrences(of: "<br />", with: "\n", options: .regularExpression, range: nil)
        str = str.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)

        if removeLineBreaks {
            str = str.replacingOccurrences(of: "\n", with: " ", options: .regularExpression, range: nil)
        }

        return str.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// From Stackoverflow https://stackoverflow.com/a/30141700
    /// Returns a new string made by replacing in the `String`
    /// all HTML character entity references with the corresponding
    /// character.
    var stringByDecodingHTMLEntities : String {

        // ===== Utility functions =====

        // Convert the number in the string to the corresponding
        // Unicode character, e.g.
        //    decodeNumeric("64", 10)   --> "@"
        //    decodeNumeric("20ac", 16) --> "€"
        func decodeNumeric(_ string : Substring, base : Int) -> Character? {
            guard let code = UInt32(string, radix: base),
                let uniScalar = UnicodeScalar(code) else { return nil }
            return Character(uniScalar)
        }

        // Decode the HTML character entity to the corresponding
        // Unicode character, return `nil` for invalid input.
        //     decode("&#64;")    --> "@"
        //     decode("&#x20ac;") --> "€"
        //     decode("&lt;")     --> "<"
        //     decode("&foo;")    --> nil
        func decode(_ entity : Substring) -> Character? {

            if entity.hasPrefix("&#x") || entity.hasPrefix("&#X") {
                return decodeNumeric(entity.dropFirst(3).dropLast(), base: 16)
            } else if entity.hasPrefix("&#") {
                return decodeNumeric(entity.dropFirst(2).dropLast(), base: 10)
            } else {
                return characterEntities[entity]
            }
        }

        // ===== Method starts here =====

        var result = ""
        var position = startIndex

        // Find the next '&' and copy the characters preceding it to `result`:
        while let ampRange = self[position...].range(of: "&") {
            result.append(contentsOf: self[position ..< ampRange.lowerBound])
            position = ampRange.lowerBound

            // Find the next ';' and copy everything from '&' to ';' into `entity`
            guard let semiRange = self[position...].range(of: ";") else {
                // No matching ';'.
                break
            }
            let entity = self[position ..< semiRange.upperBound]
            position = semiRange.upperBound

            if let decoded = decode(entity) {
                // Replace by decoded character:
                result.append(decoded)
            } else {
                // Invalid entity, copy verbatim:
                result.append(contentsOf: entity)
            }
        }
        // Copy remaining characters to `result`:
        result.append(contentsOf: self[position...])

        return result
    }
}

// Mapping from XML/HTML character entity reference to character
// From http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
private let characterEntities : [ Substring : Character ] = [
    // XML predefined entities:
    "&quot;"    : "\"",
    "&amp;"     : "&",
    "&apos;"    : "'",
    "&lt;"      : "<",
    "&gt;"      : ">",

    // HTML character entity references:
    "&nbsp;"    : "\u{00a0}",
    // ...
    "&diams;"   : "♦",
]
