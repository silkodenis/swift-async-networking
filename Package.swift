// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "AsyncNetworking",
    platforms: [
            .macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)
        ],
    products: [
        .library(
            name: "AsyncNetworking",
            targets: ["AsyncNetworking"]),
    ],
    targets: [
        .target(
            name: "AsyncNetworking",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "AsyncNetworkingTests",
            dependencies: ["AsyncNetworking"],
            path: "Tests")
    ]
)
