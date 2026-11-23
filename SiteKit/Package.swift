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
    .package(path: "../Shared")
  ],
  targets: [
    .target(
      name: "SiteCore",
      dependencies: [
        .product(name: "Shared", package: "Shared")
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
        "SiteCore",
        .product(name: "Shared", package: "Shared"),
      ],
      resources: [
        .process("Localizable.xcstrings"),
        .process("sample-shows.json"),
      ],
      swiftSettings: [
        .treatAllWarnings(as: .error),
        .enableUpcomingFeature("MemberImportVisibility"),
      ]),
    .testTarget(
      name: "SiteUITests",
      dependencies: [
        "SiteUI",
        "SiteCore",
        .product(name: "SharedTestSupport", package: "Shared"),
      ],
      swiftSettings: [
        .treatAllWarnings(as: .error),
        .enableUpcomingFeature("MemberImportVisibility"),
      ]),
    .testTarget(
      name: "SiteCoreTests",
      dependencies: [
        "SiteCore",
        .product(name: "SharedTestSupport", package: "Shared"),
      ],
      swiftSettings: [
        .treatAllWarnings(as: .error),
        .enableUpcomingFeature("MemberImportVisibility"),
      ]),
  ],
  swiftLanguageModes: [.v6]
)
