// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XcodeServerHelpers",
    platforms: [
      .macOS(.v10_13)
    ],
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
