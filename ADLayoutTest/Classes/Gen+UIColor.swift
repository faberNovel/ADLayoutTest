//
//  Gen+UIColor.swift
//  ADLayoutTest
//
//  Created by Pierre Felgines on 11/04/2019.
//

import Foundation
import SwiftCheck

extension Gen where A == UIColor {

    /// A `UIColor` random generator
    public static var color: Gen<UIColor> {
        let componentGen: Gen<CGFloat> = Gen<Int>
            .choose((0, 255))
            .map { CGFloat($0) / 255.0 }
        return Gen<UIColor>.compose { c in
            return UIColor(
                red: c.generate(using: componentGen),
                green: c.generate(using: componentGen),
                blue: c.generate(using: componentGen),
                alpha: 1.0
            )
        }
    }
}
