// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "rtt-sdk",
  platforms: [.iOS(.v17), .visionOS(.v1)],
  products: [
    .library(
      name: "rtt-sdk",
      targets: ["LiveTranslationSDK_iOS"]),
  ],
  targets: [
    .target(
      name: "rtt-sdk",
      path: "iOS/Sources"),
    .binaryTarget(
      name: "LiveTranslationSDK_iOS",
      path: "iOS/binary/LiveTranslationSDK_iOS.xcframework"
    ),
  ]
)
