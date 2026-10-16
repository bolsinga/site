// swift-tools-version: 6.2
import PackageDescription

let package = Package(
  name: "Shared",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v26),
    .macOS(.v26),
    .tvOS(.v26),
  ],
  products: [
    .library(
      name: "Shared",
      targets: ["Shared"])
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.1"),
    .package(url: "https://github.com/apple/swift-collections.git", from: "1.7.1"),
  ],
  targets: [
    .target(
      name: "Shared",
      dependencies: [
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "Collections", package: "swift-collections"),
      ],
      resources: [
        .process("Localizable.xcstrings")
      ])
  ]
)
