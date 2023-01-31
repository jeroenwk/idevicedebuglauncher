// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "idevicedebuglauncherlib",
    platforms: [
        .iOS(.v13)
        ],
    products: [
        .library(
            name: "idevicedebuglauncherlib",
            targets: ["idevicedebuglauncherlibswift", "debugutils"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "idevicedebuglauncherlibswift",
            dependencies: ["debugutils"]),
        .target(
            name: "debugutils",
            dependencies: []),
    ]
)
