//
//  ADLayoutTest_ExampleTests.swift
//  ADLayoutTest_ExampleTests
//
//  Created by Pierre Felgines on 12/04/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import XCTest
import ADLayoutTest
import SwiftCheck
import SnapshotTesting
@testable import ADLayoutTest_Example

extension UIView {
    class func fromNib<T: UIView>() -> T {
        return fromNib(named: String(describing: T.self))
    }

    class func fromNib<T: UIView>(named: String) -> T {
        return Bundle(for: T.self).loadNibNamed(named, owner: nil, options: nil)![0] as! T
    }
}

extension ExampleViewModel: Arbitrary {

    public static var arbitrary: Gen<ExampleViewModel> {
        return Gen<ExampleViewModel>.compose { c in
            return ExampleViewModel(
                image: c.generate(using: .image(min: 20, max: 100)),
                text: c.generate(using: .words),
                subText: c.generate(using: .words)
            )
        }
    }
}

class ADLayoutTest_ExampleTests: XCTestCase {

    func testExampleView() {

        runLayoutTests(named: "ExampleView") { (viewModel: ExampleViewModel) in
            let view: ExampleView = ExampleView.fromNib(named: "ExampleViewValid")
            view.backgroundColor = UIColor.white
            view.frame = CGRect(x: 0, y: 0, width: 320.0, height: 150.0)
            view.configure(with: viewModel)
            view.setNeedsLayout()
            view.layoutIfNeeded()
            do {
                try view.ad_runBasicRecursiveTests()
            } catch {
                return .failure(view, error)
            }
            return .success(view)
        }
    }

    func testExampleViewScreeshots() {

        runLayoutTests(
            named: "ExampleView Screenshots",
            snapshotStrategy: .allTests,
            maxTestsCount: 10
        ) { (viewModel: ExampleViewModel) in
            let view: ExampleView = ExampleView.fromNib(named: "ExampleViewValid")
            view.backgroundColor = UIColor.white
            view.frame = CGRect(x: 0, y: 0, width: 320.0, height: 150.0)
            view.configure(with: viewModel)
            view.setNeedsLayout()
            view.layoutIfNeeded()
            do {
                try view.ad_runBasicRecursiveTests()
            } catch {
                return .failure(view, error)
            }
            return .success(view)
        }
    }

    // This test should fail
    func testExampleViewError() {

        runLayoutTests(named: "ExampleView Overlap") { (viewModel: ExampleViewModel) in
            let view: ExampleView = ExampleView.fromNib(named: "ExampleViewError")
            view.backgroundColor = UIColor.white
            view.frame = CGRect(x: 0, y: 0, width: 320.0, height: 150.0)
            view.configure(with: viewModel)
            view.setNeedsLayout()
            view.layoutIfNeeded()
            do {
                try view.ad_runBasicRecursiveTests()
            } catch {
                return .failure(view, error)
            }
            return .success(view)
        }
    }

    func testExampleViewSavedScreenshots() {
        runLayoutTests(
            named: "ExampleView Saved Screenshots",
            randomStrategy: .consistent, // mandatory to have the same screenshots every time
            maxTestsCount: 5
        ) { (viewModel: ExampleViewModel) in
            let view: ExampleView = ExampleView.fromNib(named: "ExampleViewValid")
            view.backgroundColor = UIColor.white
            view.frame = CGRect(x: 0, y: 0, width: 320.0, height: 150.0)
            view.configure(with: viewModel)
            view.setNeedsLayout()
            view.layoutIfNeeded()
            assertSnapshot(
                matching: view,
                as: .image
            )
            // no layout assertions, we just check the generated screenshots
            return .success // we don't pass the view here because we don't care
        }
    }
}
