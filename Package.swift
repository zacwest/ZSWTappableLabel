// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZSWTappableLabel",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "ZSWTappableLabel",
            targets: ["ZSWTappableLabel"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ZSWTappableLabel",
            dependencies: [],
            publicHeadersPath: "."
        )
    ]
)
