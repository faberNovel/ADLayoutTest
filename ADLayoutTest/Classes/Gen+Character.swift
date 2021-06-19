//
//  Gen+Character.swift
//  ADLayoutTest
//
//  Created by Pierre Felgines on 11/04/2019.
//

import Foundation
import SwiftCheck
import UIKit

extension Gen where A == Character {

    /// Generator of random character between `"A"` and `"Z"`
    public static let upper = Gen<Character>.fromElements(in: "A"..."Z")

    /// Generator of random character between `"a"` and `"z"`
    public static let lower = Gen<Character>.fromElements(in: "a"..."z")

    /// Generator of random character between `"0"` and `"9"`
    public static let numeric = Gen<Character>.fromElements(in: "0"..."9")

    /// Generator of random special character
    public static let special = Gen<Character>.fromElements(
        of: [
            "!", "#", "$", "%", "&", "'", "*", "+", "-", "/", "=", "?", "^", "_", "`", "{", "|", "}", "~", "."
        ]
    )

    /// Generator of random character between `"A"` and `"Z"` or between `"0"` and `"9"`
    public static let hexDigits = Gen<Character>.one(
        of: [Gen<Character>.fromElements(in: "A"..."F"), numeric]
    )
}
