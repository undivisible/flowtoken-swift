// swift-tools-version: 6.0
import PackageDescription

let package = Package(
  name: "FlowToken",
  platforms: [
    .iOS(.v16),
    .macOS(.v13),
    .tvOS(.v16),
    .watchOS(.v9),
  ],
  products: [
    .library(name: "FlowToken", targets: ["FlowToken"])
  ],
  targets: [
    .target(name: "FlowToken"),
    .testTarget(name: "FlowTokenTests", dependencies: ["FlowToken"]),
  ]
)
