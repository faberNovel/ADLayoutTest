//
//  ExampleView.swift
//  ADLayoutTest_Example
//
//  Created by Pierre Felgines on 12/04/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import UIKit

struct ExampleViewModel {
    let image: UIImage?
    let text: String
    let subText: String
}

class ExampleView: UIView {

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var label: UILabel!
    @IBOutlet private var subLabel: UILabel!

    // MARK: - Public

    func configure(with viewModel: ExampleViewModel) {
        imageView.image = viewModel.image
        label.text = viewModel.text
        subLabel.text = viewModel.subText
    }
}
