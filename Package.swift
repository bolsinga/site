// swift-tools-version:5.10

import PackageDescription

let package = Package(
  name: "site",
  defaultLocalization: "en",
  platforms: [
    .macOS("14.4"),
    .iOS("17.4"),
    .tvOS("17.4"),
  ],
  products: [
    .library(name: "Site", targets: ["Site"]),
    .executable(name: "site_tool", targets: ["site_tool"]),
    .executable(name: "site_associated_domains", targets: ["site_associated_domains"]),
    .executable(name: "next_id", targets: ["next_id"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.4.0")
  ],
  targets: [
    .target(
      name: "Site",
      resources: [.process("Resources/Localizable.xcstrings")],
      swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]),
    .testTarget(name: "SiteTests", dependencies: ["Site"]),
    .executableTarget(
      name: "site_tool",
      dependencies: [
        .byName(name: "Site"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]),
    .executableTarget(
      name: "site_associated_domains",
      dependencies: [
        .product(name: "ArgumentParser", package: "swift-argument-parser")
      ]),
    .executableTarget(
      name: "next_id",
      dependencies: [
        .byName(name: "Site"),
        .product(name: "ArgumentParser", package: "swift-argument-parser"),
      ]),
  ]
)
