// swift-tools-version: 6.4
import PackageDescription

let package = Package(
  name: "SiteKit",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v27),
    .macOS(.v27),
    .tvOS(.v27),
  ],
  products: [
    .library(
      name: "SiteCore",
      targets: ["SiteCore"]),
    .library(
      name: "SiteUI",
      targets: ["SiteUI"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-algorithms.git", from: "1.2.1"),
    .package(url: "https://github.com/apple/swift-collections.git", from: "1.7.1"),
  ],
  targets: [
    .target(
      name: "SiteCore",
      dependencies: [
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "Collections", package: "swift-collections"),
      ],
      resources: [
        .process("Localizable.xcstrings")
      ],
      swiftSettings: [
        .treatAllWarnings(as: .error),
        .enableUpcomingFeature("MemberImportVisibility"),
      ]),
    .target(
      name: "SiteUI",
      dependencies: [
        "SiteCore"
      ],
      resources: [
        .process("Localizable.xcstrings"),
        .process("sample-shows.json"),
      ],
      swiftSettings: [
        .treatAllWarnings(as: .error),
        .enableUpcomingFeature("MemberImportVisibility"),
      ]),
    .target(
      name: "SiteTestSupport",
      dependencies: ["SiteCore"],
      swiftSettings: [
        .treatAllWarnings(as: .error),
        .enableUpcomingFeature("MemberImportVisibility"),
      ]),
    .testTarget(
      name: "SiteUITests",
      dependencies: ["SiteUI", "SiteCore", "SiteTestSupport"],
      swiftSettings: [
        .treatAllWarnings(as: .error),
        .enableUpcomingFeature("MemberImportVisibility"),
      ]),
    .testTarget(
      name: "SiteCoreTests",
      dependencies: ["SiteCore", "SiteTestSupport"],
      swiftSettings: [
        .treatAllWarnings(as: .error),
        .enableUpcomingFeature("MemberImportVisibility"),
      ]),
  ],
  swiftLanguageModes: [.v6]
)
