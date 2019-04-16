//
//  Gen+String.swift
//  ADLayoutTest
//
//  Created by Pierre Felgines on 11/04/2019.
//

import Foundation
import SwiftCheck

extension String {

    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
}

func glue(_ parts: [Gen<String>]) -> Gen<String> {
    return sequence(parts).map { $0.reduce("", +) }
}

extension Gen where A == String {

    private static let lipsumWord: Gen<String> = {
        let text = """
Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Donec id elit non mi porta gravida at eget metus. Curabitur blandit tempus porttitor. Donec id elit non mi porta gravida at eget metus. Integer posuere erat a ante venenatis dapibus posuere velit aliquet. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Cras justo odio, dapibus ac facilisis in, egestas eget quam. Aenean lacinia bibendum nulla sed consectetur. Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Etiam porta sem malesuada magna mollis euismod.
"""
        let words = text
            .replacingOccurrences(of: ".", with: "")
            .replacingOccurrences(of: ",", with: "")
            .lowercased()
            .split(separator: " ")
            .map { String($0) }
        return fromElements(of: words)
    }()

    /// A string random generator for a word with a capitalized letter
    ///
    /// Example: `"Lipsum"`
    public static let word = lipsumWord
        .map { $0.capitalizingFirstLetter() }

    /// A string random generator for words with the first word capitalized
    ///
    /// Example: `"Duis mollis est"`
    public static let words = lipsumWord
        .proliferateNonEmpty
        .map {
            ($0.prefix(1).map { $0.capitalizingFirstLetter() } + $0.dropFirst()).joined(separator: " ")
        }

    /// A string random generator for sentences
    ///
    /// Example: `"Duis mollis est. Non commodo luctus."`
    public static let sentences = words
        .proliferateNonEmpty
        .map { $0.map { $0 + "." }.joined(separator: " ") }

    /// A email random generator
    public static let email: Gen<String> = {
        let localEmail = Gen<Character>
            .one(of: [.upper, .lower, .numeric, .special])
            .proliferateNonEmpty
            .suchThat { $0[($0.endIndex - 1)] != "." }
            .map { String($0) }

        let hostname = Gen<Character>
            .one(of: [.lower, .numeric, Gen<Character>.pure("-")])
            .proliferateNonEmpty
            .map { String($0) }

        let tld = Gen<Character>.lower
            .proliferateNonEmpty
            .suchThat { $0.count > 1 }
            .map { String($0) }

        return glue([localEmail, Gen.pure("@"), hostname, Gen.pure("."), tld])
    }()
}
