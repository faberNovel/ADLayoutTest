// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "ADLayoutTest",
    products: [
        .library(
            name: "ADLayoutTest",
            targets: ["ADLayoutTest"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/faberNovel/ADAssertLayout.git", from: "1.0.1"),
        .package(url: "https://github.com/typelift/SwiftCheck.git", from: "0.12.0")
    ],
    targets: [
        .target(
            name: "ADLayoutTest",
            dependencies: ["ADAssertLayout", "SwiftCheck"],
            path: "ADLayoutTest"
        )
    ]
)
