// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EyeRelaxer",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "EyeRelaxer", targets: ["EyeRelaxer"])
    ],
    targets: [
        .executableTarget(
            name: "EyeRelaxer",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
