// swift-tools-version:6.1

import PackageDescription

let package = Package(
  name: "site",
  defaultLocalization: "en",
  platforms: [
    .macOS("15.5"),
    .iOS("18.5"),
    .tvOS("18.5"),
  ],
  products: [
    .library(name: "Site", targets: ["Site"]),
    .executable(name: "site_tool", targets: ["site_tool"]),
    .executable(name: "site_associated_domains", targets: ["site_associated_domains"]),
    .executable(name: "next_id", targets: ["next_id"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser", from: "1.6.1"),
    .package(url: "https://github.com/bolsinga/PackageBuildInfo", from: "2.0.1"),
  ],
  targets: [
    .target(
      name: "Site",
      resources: [.process("Resources/Localizable.xcstrings")],
      plugins: [.plugin(name: "PackageBuildInfoPlugin", package: "PackageBuildInfo")]),
    .testTarget(
      name: "SiteTests", dependencies: ["Site"]),
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
