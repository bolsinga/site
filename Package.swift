// swift-tools-version:5.8

import PackageDescription

let package = Package(
  name: "site",
  defaultLocalization: "en",
  platforms: [
    .macOS(.v13),
    .iOS(.v16),
  ],
  products: [
    .library(name: "Site", targets: ["Site"]),
    .executable(name: "site_tool", targets: ["site_tool"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.2"),
    .package(url: "https://github.com/bolsinga/LoadingState", branch: "main"),
  ],
  targets: [
    .target(name: "Site", dependencies: [.product(name: "LoadingState", package: "LoadingState")]),
    .testTarget(name: "SiteTests", dependencies: ["Site"]),
    .executableTarget(
      name: "site_tool",
      dependencies: [
        .byName(name: "Site"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]),
  ]
)
