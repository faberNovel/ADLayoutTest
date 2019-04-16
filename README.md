# ADLayoutTest

[![Version](https://img.shields.io/cocoapods/v/ADLayoutTest.svg?style=flat)](https://cocoapods.org/pods/ADLayoutTest)
[![License](https://img.shields.io/cocoapods/l/ADLayoutTest.svg?style=flat)](https://cocoapods.org/pods/ADLayoutTest)
[![Platform](https://img.shields.io/cocoapods/p/ADLayoutTest.svg?style=flat)](https://cocoapods.org/pods/ADLayoutTest)

ADLayoutTest is an example of implementation of property based testing for UI layouts.

The main idea is to generate random view inputs (with [SwiftCheck](https://github.com/typelift/SwiftCheck)), layout the view, then assert some layout properties are true (with [ADAssertLayout](https://github.com/applidium/ADAssertLayout)).

We can leverage the same idea to make snapshot tests.

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Communication](#communication)
- [Credits](#credits)
- [License](#license)

## Features

### Example

You can find an example of use in the [Example](/tree/master/Example) directory.

Let's say we use the following view in our app, and we want to test it:

```swift
import Foundation
import UIKit

struct ExampleViewModel {
    let image: UIImage?
    let text: String
    let subText: String
}

class ExampleView: UIView {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var label: UILabel!
    @IBOutlet var subLabel: UILabel!

    // MARK: - Public

    func configure(with viewModel: ExampleViewModel) {
        imageView.image = viewModel.image
        label.text = viewModel.text
        subLabel.text = viewModel.subText
    }
}
```

We want to generate random view models to configure the view.
For this we use SwiftCheck to make `ExampleViewModel` conforms to `Arbitrary`.
That way we have a random generator of `ExampleViewModel`.

```swift
import SwiftCheck

extension ExampleViewModel: Arbitrary {

    // This is a random generator of `ExampleViewModel`
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
```

The generators `.image(min: 20, max: 100)` and `.words` are [custom](#built-in-generators) generators that create random instances of images or strings.

A basic test case that verify the `ExampleView` layout is:

```swift
import XCTest
import ADAssertLayout
import ADLayoutTest

class ADLayoutTest_ExampleTests: XCTestCase {

    func testExampleView() {

        runLayoutTests(named: "ExampleView") { (viewModel: ExampleViewModel) in
            // create the view we want to test
            let view: ExampleView = ExampleView.fromNib(named: "ExampleViewValid")

            // setup the view and pass the random view model
            view.backgroundColor = UIColor.white
            view.frame = CGRect(x: 0, y: 0, width: 320.0, height: 150.0)
            view.configure(with: viewModel)

            // layout the view
            view.setNeedsLayout()
            view.layoutIfNeeded()

            // run layout assertions (no view overlap, no ambiguous layout, etc)
            do {
                try view.ad_runBasicRecursiveTests()
            } catch {
                return .failure(view, error)
            }
            return .success(view)
        }
    }
}
```

In an error occurs, you can find the reason in the logs.

```
Test Case '-[ADLayoutTest_ExampleTests.ADLayoutTest_ExampleTests testExampleViewError]' started.
/Users/felginep/Sources/ADLayoutTest/Example/ADLayoutTest_ExampleTests/ADLayoutTest_ExampleTests.swift:83: error: -[ADLayoutTest_ExampleTests.ADLayoutTest_ExampleTests testExampleViewError] : failed - Bottom right corner of <UIImageView: 0x7f8af7c293e0; frame = (20 20; 70 70); clipsToBounds = YES; opaque = NO; autoresize = RM+BM; userInteractionEnabled = NO; layer = <CALayer: 0x60000220cd20>> (superview: <ADLayoutTest_Example.ExampleView: 0x7f8af7c291e0; frame = (0 0; 320 150); autoresize = W+H; layer = <CALayer: 0x60000220ce00>>) overlaps upper left corner of <UILabel: 0x7f8af7c29610; frame = (62 20; 238 20.5); text = 'Erat porta eget venenatis...'; opaque = NO; autoresize = RM+BM; userInteractionEnabled = NO; layer = <_UILabelLayer: 0x600000159770>> (superview: <ADLayoutTest_Example.ExampleView: 0x7f8af7c291e0; frame = (0 0; 320 150); autoresize = W+H; layer = <CALayer: 0x60000220ce00>>).
*** Failed! Proposition: ExampleView Overlap
Falsifiable (after 9 tests):
ExampleViewModel(image: Optional(<UIImage: 0x6000009a4380>, {36, 79}), text: "Erat porta eget venenatis porta", subText: "Elit elit etiam dapibus at erat")
*** Passed 8 tests
.
error: -[ADLayoutTest_ExampleTests.ADLayoutTest_ExampleTests testExampleViewError] : failed - Falsifiable; Replay with 904979560 363827163 and size 8
```

Note that you can see which input caused the layout error:

```swift
ExampleViewModel(
    image: Optional(<UIImage: 0x6000009a4380>, {36, 79}),
    text: "Erat porta eget venenatis porta",
    subText: "Elit elit etiam dapibus at erat"
)
```

If you want to reproduce the same error for debug purposes, you can use the log message to replay the test using the custom random strategy `.replay`.

```
Falsifiable; Replay with 904979560 363827163 and size 8
```

The parameter is then:

```swift
.replay(
    seed1: 904979560,
    seed2: 363827163,
    size: 8
)
```

If you go in the test report, you can find a snapshot of the failing view with the layout error highlighted.

![Test Report Failure](/assets/test_report_failure.png)
![Failure Overlap Highlighted](/assets/failure_overlap_highlighted.png)

### Parameters

You can pass some parameters to the `runLayoutTests` function:

- `snapshotStrategy`: by default, with `.failureOnly` when the test fails, a snapshot is taken and is displayed in the test report. If you want to snapshot every view with every input, you can pass the `.allTests` parameter.
- `randomStrategy`: by default, with `random` real random values are generated (meaning you won't have the same view models for two different test executions). If you want to have consistent inputs, use the `.consitent` or `.replay` parameters.
- `maxTestsCount`: by default 100 tests are run. You can lower the value if needed.

### Return value

The `runLayoutTests` function takes a closure in parameter. This closure returns a `ViewAssertionResult`. This result contains two optional values: a `view` and an `error`.
If present, the `view` is used to take a screenshot and display it in the test report.
If an `error` is returned, the test fails.

### Snapshot testing

You can use the same technique to create snapshot tests, and assert your view does not change visually during the development.
For this, import a snapshot testing library (in the example we use [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing)) and use the `runLayoutTests` function with a random strategy of `.consitent` to generate always the same random values.

```swift
    func testExampleViewSavedScreenshots() {
        runLayoutTests(
            named: "ExampleView Saved Screenshots",
            randomStrategy: .consistent, // mandatory to have the same screenshots every time
            maxTestsCount: 5 // we only want 5 screenshots
        ) { (viewModel: ExampleViewModel) in
            // same code as before
            let view: ExampleView = ExampleView.fromNib(named: "ExampleViewValid")
            view.backgroundColor = UIColor.white
            view.frame = CGRect(x: 0, y: 0, width: 320.0, height: 150.0)
            view.configure(with: viewModel)
            view.setNeedsLayout()
            view.layoutIfNeeded()

            // Snapshot the view (depends of the library used)
            assertSnapshot(
                matching: view,
                as: .image
            )

            // no layout assertions, we just check the generated screenshots
            return .success // we don't pass the view here because we don't care
        }
    }
```

### Built-in generators

You can find some useful predefined generators that you can use to create your random inputs.

- [`Gen<Character>`](/blob/master/ADLayoutTest/Classes/Gen+Character.swift): `.upper`, `.lower`, `.numeric`, `.special`, `.hexDigits`
- [`Gen<String>`](/blob/master/ADLayoutTest/Classes/Gen+String.swift): `.word`, `.words`, `.sentences`, `email` (word and sentences are built with lorem ipsum content)
- [`Gen<UIColor>`](/blob/master/ADLayoutTest/Classes/Gen+UIColor.swift): `.color`
- [`Gen<UIImage>`](/blob/master/ADLayoutTest/Classes/Gen+UIImage.swift): `.image(min:max:)`

Feel free to leverage the `Gen` type to create your own generators. You can find all the documentation on the [SwiftCheck](https://github.com/typelift/SwiftCheck/blob/master/Sources/SwiftCheck/Gen.swift) page.

## Requirements

- iOS 9.0+
- Swift 4.2

## Installation

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate ADLayoutTest into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'ADLayoutTest'
end
```

Then, run the following command:

```bash
$ pod install
```

## Communication

- If you **need help**, use [Twitter](https://twitter.com/applidium).
- If you'd like to **ask a general question**, use [Twitter](https://twitter.com/applidium).
- If you'd like to **apply for a job**, [email us](jobs@applidium.com).
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Credits

ADLayoutTest is owned and maintained by [Fabernovel Technologies](https://technologies.fabernovel.com/). You can follow us on Twitter at [@applidium](https://twitter.com/applidium).

## License

ADLayoutTest is released under the MIT license. [See LICENSE](LICENSE) for details.
