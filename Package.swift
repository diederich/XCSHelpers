// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XCSHelpers",
    platforms: [
      .macOS(.v10_13)
    ],
    products: [
      .executable(name: "SlackPostIntegrationPost", targets: ["SlackPostIntegrationPost"])
    ],
    dependencies: [
      .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "SlackPostIntegrationPost",
            dependencies: [
                "XCSHelpersKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]
        ),
        .target(name: "XCSHelpersKit"),
        .testTarget(
            name: "SlackPostIntegrationPostTests",
            dependencies: ["SlackPostIntegrationPost"]
        ),
    ]
)
