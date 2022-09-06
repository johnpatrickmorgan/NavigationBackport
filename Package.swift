// swift-tools-version: 5.5

import PackageDescription

let package = Package(
  name: "NavigationBackport",
  platforms: [
    .iOS(.v13), .watchOS(.v7), .macOS(.v11), .tvOS(.v13),
  ],
  products: [
    .library(
      name: "NavigationBackport",
      targets: ["NavigationBackport"]
    ),
  ],
  dependencies: [
    .package(url: "git@github.com:shaps80/SwiftUIBackports.git", exact: "1.6.2"),
  ],
  targets: [
    .target(
      name: "NavigationBackport",
      dependencies: [
        "SwiftUIBackports",
      ]
    ),
    .testTarget(
      name: "NavigationBackportTests",
      dependencies: ["NavigationBackport"]
    ),
  ]
)
