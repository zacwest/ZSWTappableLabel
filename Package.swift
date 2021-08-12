// swift-tools-version:5.3

import PackageDescription

public let package = Package(
    name: "ZSWTappableLabel",
    platforms: [
        .iOS(.v10),
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
            path: "ZSWTappableLabel",
            publicHeadersPath: "Public"
        ),
    ]
)
