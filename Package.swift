// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "galaxy-labs",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        .executable(name: "GalaxyLabs", targets: ["GalaxyLabs"]),
        .library(name: "Sensor", targets: ["Sensor"]),
        .library(name: "Context", targets: ["Context"]),
        .library(name: "Agent", targets: ["Agent"]),
        .library(name: "Actions", targets: ["Actions"]),
        .library(name: "Behavior", targets: ["Behavior"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.5.0"),
    ],
    targets: [
        .executableTarget(
            name: "GalaxyLabs",
            dependencies: [
                "Sensor",
                "Context",
                "Agent",
                "Actions",
                "Behavior",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ],
            path: "apps/desktop/Sources/GalaxyLabs"
        ),
        .target(name: "Sensor", path: "packages/Sensor/Sources/Sensor"),
        .target(
            name: "Context",
            dependencies: ["Sensor"],
            path: "packages/Context/Sources/Context"
        ),
        .target(
            name: "Behavior",
            path: "packages/Behavior/Sources/Behavior"
        ),
        .target(
            name: "Agent",
            dependencies: ["Context", "Behavior"],
            path: "packages/Agent/Sources/Agent"
        ),
        .target(
            name: "Actions",
            dependencies: ["Behavior", "Agent"],
            path: "packages/Actions/Sources/Actions"
        ),
        // Re-enable after installing full Xcode (CLT has no XCTest / Swift Testing):
        // .testTarget(
        //     name: "GalaxyLabsTests",
        //     dependencies: ["Sensor", "Context", "Agent", "Actions", "Behavior"],
        //     path: "Tests/GalaxyLabsTests"
        // ),
    ]
)
