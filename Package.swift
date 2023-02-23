// swift-tools-version:5.7

import PackageDescription

let package = Package(
  name: "site",
  defaultLocalization: "en",
  platforms: [
    .macOS(.v13),
    .iOS(.v16),
  ],
  products: [
    .library(name: "Diary", targets: ["Diary"]),
    .library(name: "Music", targets: ["Music"]),
    .executable(name: "site_tool", targets: ["site_tool"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.2"),
    .package(url: "https://github.com/bolsinga/LoadingState", branch: "main"),
  ],
  targets: [
    .target(name: "Diary", dependencies: []),
    .target(name: "Music", dependencies: []),
    .executableTarget(
      name: "site_tool",
      dependencies: [
        .byName(name: "Diary"),
        .byName(name: "Music"),
        .product(name: "LoadingState", package: "LoadingState"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]),
  ]
)
