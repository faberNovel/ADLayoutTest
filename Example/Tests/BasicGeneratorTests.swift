//
//  BasicGeneratorTests.swift
//  ADLayoutTest_Example
//
//  Created by Pierre Felgines on 11/04/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import XCTest
import ADLayoutTest
import SwiftCheck

extension CharacterSet {

    func contains(_ c: Character) -> Bool {
        return c.unicodeScalars.allSatisfy { contains($0) }
    }
}

// We can't make UIColor conform to Arbitrary because it is not a struct
// That's why we need to wrap it in a struct.
struct Color: Arbitrary {

    let uiColor: UIColor

    static var arbitrary: Gen<Color> {
        return Gen<UIColor>.color.map(self.init)
    }
}

class BasicGeneratorTests: XCTestCase {

    func testColorGen() {
        // We need these seeds to be sure the two colors at the end are not the same
        let seed1Arg = CheckerArguments(
            replay: (StdGen(0, 0), 1),
            maxAllowableSuccessfulTests: 1
        )
        let seed2Arg = CheckerArguments(
            replay: (StdGen(1, 2), 1),
            maxAllowableSuccessfulTests: 1
        )
        var colors1: [UIColor] = []
        property("_", arguments: seed1Arg) <- forAll { (color: Color) in
            colors1.append(color.uiColor)
            return true
        }
        var colors2: [UIColor] = []
        property("_", arguments: seed2Arg) <- forAll { (color: Color) in
            colors2.append(color.uiColor)
            return true
        }
        XCTAssertEqual(colors1.count, colors2.count)
        XCTAssertNotEqual(colors1, colors2)
    }

    func testImageGen() {
        let image1 = Gen<UIImage>.image(min: 10, max: 20).generate
        let image2 = Gen<UIImage>.image(min: 100, max: 200).generate
        XCTAssertNotEqual(image1.size, .zero)
        XCTAssert(image1.size.width >= 10)
        XCTAssert(image1.size.height >= 10)
        XCTAssert(image1.size.width <= 20)
        XCTAssert(image1.size.height <= 20)
        XCTAssert(image2.size.width >= 100)
        XCTAssert(image2.size.height >= 100)
        XCTAssert(image2.size.width <= 200)
        XCTAssert(image2.size.height <= 200)
    }

    func testCharacterGen() {
        let upperChar = Gen<Character>.upper.generate
        XCTAssertTrue(CharacterSet.uppercaseLetters.contains(upperChar))

        let lowerChar = Gen<Character>.lower.generate
        XCTAssertTrue(CharacterSet.lowercaseLetters.contains(lowerChar))

        let numericChar = Gen<Character>.numeric.generate
        XCTAssertTrue(CharacterSet.decimalDigits.contains(numericChar))

        let specialChar = Gen<Character>.special.generate
        XCTAssertTrue(CharacterSet.punctuationCharacters.union(.symbols).contains(specialChar))

        let hexChar = Gen<Character>.hexDigits.generate
        XCTAssertTrue(CharacterSet.decimalDigits.union(.uppercaseLetters).contains(hexChar))
    }

    func testStringGen() {
        let word = Gen<String>.word.generate
        XCTAssertFalse(word.isEmpty)
        XCTAssertEqual((word as NSString).rangeOfCharacter(from: .uppercaseLetters).location, 0)
        XCTAssertEqual((word as NSString).rangeOfCharacter(from: .lowercaseLetters).location, 1)
        XCTAssertEqual((word as NSString).rangeOfCharacter(from: .whitespaces).location, NSNotFound)

        let words = Gen<String>.words.generate
        XCTAssertFalse(words.isEmpty)
        XCTAssertEqual((words as NSString).rangeOfCharacter(from: .uppercaseLetters).location, 0)

        let sentences = Gen<String>.sentences.generate
        XCTAssertEqual((sentences as NSString).rangeOfCharacter(from: .uppercaseLetters).location, 0)
        XCTAssertNotEqual((sentences as NSString).rangeOfCharacter(from: .punctuationCharacters).location, NSNotFound)

        let email = Gen<String>.email.generate
        XCTAssertTrue(email.contains("@"))
    }
}
