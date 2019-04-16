//
//  XCTActivity+Screenshot.swift
//  ADLayoutTest
//
//  Created by Pierre Felgines on 10/04/2019.
//

import Foundation
import UIKit
import XCTest

extension UIView {

    func snapshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension XCTActivity {

    func addAttachment(from view: UIView, named: String? = nil) {
        guard let image = view.snapshot() else { return }
        let attachment = XCTAttachment(image: image)
        attachment.name = named
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
