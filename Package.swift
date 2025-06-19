// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "json-support",
    platforms: [
        .iOS(.v16),
        .tvOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
    ],
    products: [
        .library(
            name: "JSONSupport",
            targets: ["JSONSupport"]
        )
    ],
    targets: [
        .target(name: "JSONSupport"),
        .testTarget(
            name: "JSONSupportTests",
            dependencies: ["JSONSupport"]
        ),
    ]
)
