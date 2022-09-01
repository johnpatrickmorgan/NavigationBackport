// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "NavigationBackport",
  platforms: [
    .iOS(.v14), .watchOS(.v7), .macOS(.v11), .tvOS(.v14),
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
