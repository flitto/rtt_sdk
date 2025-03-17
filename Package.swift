// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "rtt-sdk",
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
//    .binaryTarget(
//      name: "LiveTranslationSDK_iOS",
//      url: "https://github.com/flitto/rtt_sdk/blob/main/ios/binary/LiveTranslationSDK_iOS.xcframework",
//      checksum: "0566a694dc3ad4c8f5a0f30f149dec4d4edf14af6c7d5e3d11dafbd18999f12c")

  ]
)
