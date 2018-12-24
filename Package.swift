// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "action-swiftlint",
    products: [
        .executable(name: "action-swiftlint", targets: ["action-swiftlint"]),
    ],
    targets: [
        .target(
            name: "action-swiftlint",
            dependencies: ["Lib"]),
        .target(name: "Lib"),
        .testTarget(
            name: "action-swiftlintTests",
            dependencies: ["action-swiftlint", "Lib"]),
    ]
)
