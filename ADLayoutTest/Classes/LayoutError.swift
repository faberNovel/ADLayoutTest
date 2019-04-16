//
//  LayoutError.swift
//  ADAssertLayout
//
//  Created by Pierre Felgines on 10/04/2019.
//

import Foundation
import ADAssertLayout

extension UIView {

    func ad_border() {
        layer.borderWidth = 1.0
        layer.borderColor = UIColor.red.cgColor
    }

    func ad_unborder() {
        layer.borderWidth = 0.0
        layer.borderColor = UIColor.clear.cgColor
    }
}

public protocol LayoutError {
    func highlightLayoutErrors()
}

extension OverlapError: LayoutError {

    // MARK: - LayoutError

    public func highlightLayoutErrors() {
        leftMostSubview.ad_border()
        rightMostSubview.ad_border()
    }
}

extension AssertFrameViewError: LayoutError {

    // MARK: - LayoutError

    public func highlightLayoutErrors() {
        view.ad_border()
    }
}

extension AmbiguousLayoutError: LayoutError {

    // MARK: - LayoutError

    public func highlightLayoutErrors() {
        view.ad_border()
    }
}
