//
//  Gen+UIImage.swift
//  ADLayoutTest
//
//  Created by Pierre Felgines on 11/04/2019.
//

import Foundation
import UIKit
import SwiftCheck

extension UIImage {

    /// Create an image from a solid color
    ///
    /// - parameter color: The background color of the image
    /// - parameter size: The size of the generated image
    ///
    /// Returns an empty image if a problem occurs.
    static func image(with color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image ?? UIImage()
    }
}

extension Gen where A == UIImage {

    /// A `UIImage` random generator
    ///
    /// - parameter min: Min size for width or height
    /// - parameter max: Max size for width or height
    public static func image(min: Int, max: Int) -> Gen<UIImage> {
        let sizeGen = Gen<Int>.choose((min, max))
        return Gen<UIImage>.compose { c in
            return UIImage.image(
                with: c.generate(using: .color),
                size: CGSize(
                    width: c.generate(using: sizeGen),
                    height: c.generate(using: sizeGen)
                )
            )
        }
    }
}
