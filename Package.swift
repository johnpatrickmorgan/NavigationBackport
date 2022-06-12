// swift-tools-version: 5.6

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
  dependencies: [],
  targets: [
    .target(
      name: "NavigationBackport",
      dependencies: []
    ),
    .testTarget(
      name: "NavigationBackportTests",
      dependencies: ["NavigationBackport"]
    ),
  ]
)
