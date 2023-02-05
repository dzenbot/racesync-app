//
//  String+Extensions.swift
//  RaceSyncAPI
//
//  Created by Ignacio Romero Zurbuchen on 2021-01-07.
//  Copyright © 2021 MultiGP Inc. All rights reserved.
//

import Foundation

public extension String {

    func lowercasedWords() -> [String] {
        return self.lowercased().components(separatedBy: " ")
    }

    // Returns a substring to specific limit or the max character count
    // without throwing an exception
    func safeSubstring(to index: Int) -> String {
        let idx = (index > count) ? count : index
        let str = self
        return String(str[..<str.index(str.startIndex, offsetBy: idx)])
    }

    /// A string with the ' characters in it escaped.
    /// Used when passing a string into JavaScript, so the string is not completed too soon
    var escaped: String {
        let unicode = self.unicodeScalars
        var newString = ""
        for char in unicode {
            if char.value == 39 || // 39 == ' in ASCII
                char.value < 9 ||  // 9 == horizontal tab in ASCII
                (char.value > 9 && char.value < 32) // < 32 == special characters in ASCII
            {
                let escaped = char.escaped(asASCII: true)
                newString.append(escaped)
            } else {
                newString.append(String(char))
            }
        }
        return newString
    }
}

public extension String {

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
