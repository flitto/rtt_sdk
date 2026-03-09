// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "rtt-sdk",
  platforms: [
    .iOS(.v17),
    .macOS(.v15),
    .visionOS(.v2),
  ],
  products: [
    .library(
      name: "rtt-sdk",
      targets: ["LiveTranslationSDK"]),
  ],
  targets: [
    .target(
      name: "rtt-sdk",
      path: "ios/Sources"),
    .binaryTarget(
      name: "LiveTranslationSDK",
      path: "ios/binary/LiveTranslationSDK.xcframework"
    ),
  ]
)
