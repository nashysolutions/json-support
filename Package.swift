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
            targets: ["JSONSupport"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", .upToNextMinor(from: "1.8.1")),
        .package(url: "https://github.com/nashysolutions/foundation-dependencies.git", .upToNextMinor(from: "4.0.0"))
    ],
    targets: [
        .target(
            name: "JSONSupport",
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "FoundationDependencies", package: "foundation-dependencies"),
            ]
        ),
        .testTarget(
            name: "JSONSupportTests",
            dependencies: ["JSONSupport"]
        ),
    ]
)
