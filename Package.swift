// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XcodeServerHelpers",
    products: [
      .executable(name: "SlackPostIntegrationPost", targets: ["SlackPostIntegrationPost"])
    ],
    dependencies: [
      .package(url: "https://github.com/apple/swift-package-manager.git", .branch("master")),
    ],
    targets: [
        .target(
            name: "SlackPostIntegrationPost",
            dependencies: ["XcodeServerHelpersKit"]),
        .target(
          name: "XcodeServerHelpersKit",
          dependencies: ["SPMUtility"]),
        .testTarget(
            name: "SlackPostIntegrationPostTests",
            dependencies: ["SlackPostIntegrationPost"]),
        .testTarget(
          name: "XcodeServerHelpersKitTests",
          dependencies: ["XcodeServerHelpersKit"]),
    ]
)
