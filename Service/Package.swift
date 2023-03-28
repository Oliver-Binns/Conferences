// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Service",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "Service", targets: ["Service"]),
    ],
    targets: [
        .target(name: "Service"),
        .testTarget(name: "ServiceTests", dependencies: ["Service"]),
    ]
)
