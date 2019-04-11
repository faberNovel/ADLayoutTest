//
//  XCTestCase+LayoutTests.swift
//  ADLayoutTest
//
//  Created by Pierre Felgines on 10/04/2019.
//

import Foundation
import UIKit
import XCTest
import SwiftCheck
import ADAssertLayout

extension TestResult {

    var isFailure: Bool {
        switch match {
        case .matchResult(false, _, _, _, _, _, _, _, _):
            return true
        default:
            return false
        }
    }
}

extension XCTestCase {

    /// The strategy of the snapshot during the test
    public enum SnapshotStrategy {
        /// A screenshot is taken for each test
        case allTests
        /// A screenshot is taken only when the test fails
        case failureOnly
    }

    /// The strategy for random generation
    public enum RandomStrategy {
        /// True random
        case random

        /// Replayable value
        case replay(seed1: Int, seed2: Int, size: Int)

        /// No random
        public static var consistent: RandomStrategy = .replay(
            seed1: 0,
            seed2: 0,
            size: 0
        )
    }

    /// Result to pass the current tested view and an error if any
    public enum ViewAssertionResult {
        case success(UIView)
        case failure(UIView, Error)
    }

    /// Run a layout test. By default, 100 `A` instances will be generated
    /// and passed to the `run` function.
    ///
    /// - parameter named: The name of the test
    /// - parameter snapshotStrategy: The strategy for taking screenshot (for all tests or only for failure ones)
    /// - parameter randomStrategy: The strategy for randomness (truly random or no random at all)
    /// - parameter maxTestsCount: The number of generated tests. Default is 100 but lower the value if it suits you.
    /// - parameter run: The test run for each generated value
    public func runLayoutTests<A>(named: String,
                                  snapshotStrategy: SnapshotStrategy = .failureOnly,
                                  randomStrategy: RandomStrategy = .random,
                                  maxTestsCount: Int = 100,
                                  file: StaticString = #file,
                                  line: UInt = #line,
                                  run: @escaping (A) -> ViewAssertionResult) where A: Arbitrary {
        XCTContext.runActivity(named: named) { activity in
            var snapshotView: UIView?
            var layoutError: LayoutError?

            let callbackFunction = { (state: CheckerState, result: TestResult) in
                guard let snapshotView = snapshotView else { return }
                activity.addAttachment(from: snapshotView, named: "\(named)_default")

                // Take another screenshot if error
                guard result.isFailure, let layoutError = layoutError else { return }
                layoutError.highlightLayoutErrors()
                activity.addAttachment(from: snapshotView, named: "\(named)_highlight")
            }
            let callback: Callback
            switch snapshotStrategy {
            case .allTests:
                callback = .afterTest(kind: .counterexample, callbackFunction)
            case .failureOnly:
                callback = .afterFinalFailure(kind: .counterexample, callbackFunction)
            }

            let arguments = checkerArguments(
                for: randomStrategy,
                maxTestsCount: maxTestsCount
            )
            property(named, arguments: arguments) <- forAll { (a: A) in
                switch run(a) {
                case let .success(view):
                    snapshotView = view
                    return true
                case let .failure(view, error):
                    snapshotView = view
                    layoutError = error as? LayoutError
                    XCTFail(error.localizedDescription, file: file, line: line)
                    return false
                }
            }.withCallback(callback)
        }
    }

    // MARK: - Private

    private func checkerArguments(for randomStrategy: RandomStrategy,
                                  maxTestsCount: Int) -> CheckerArguments {
        switch randomStrategy {
        case .random:
            return CheckerArguments(
                maxAllowableSuccessfulTests: maxTestsCount
            )
        case let .replay(seed1: seed1, seed2: seed2, size: size):
            return CheckerArguments(
                replay: (StdGen(seed1, seed2), size),
                maxAllowableSuccessfulTests: maxTestsCount
            )
        }
    }
}

