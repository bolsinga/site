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
  targets: [
    .target(name: "json"),
    .executableTarget(name: "site_tool", dependencies: [.byName(name: "json")]),
  ]
)
