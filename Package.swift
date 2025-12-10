// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "LocationRegisterKit",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "LocationRegisterKit",
            targets: ["LocationRegisterKit"]
        ),
    ],
    targets: [
        .target(
            name: "LocationRegisterKit",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "LocationRegisterKitTests",
            dependencies: ["LocationRegisterKit"]
        ),
    ]
)
