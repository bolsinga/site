// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "site",
  platforms: [
    .macOS(.v13)
  ],
  products: [
    .library(name: "json", targets: ["json"]),
    .executable(name: "site_tool", targets: ["site_tool"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.2"),
    .package(url: "https://github.com/bolsinga/LoadingState", branch: "main"),
  ],
  targets: [
    .target(name: "json", dependencies: [.product(name: "LoadingState", package: "LoadingState")]),
    .executableTarget(
      name: "site_tool",
      dependencies: [
        .byName(name: "json"), .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]),
  ]
)
