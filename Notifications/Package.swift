// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Notifications",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "Notifications", targets: ["Notifications"]),
    ],
    dependencies: [
        .package(path: "../Model"),
        .package(path: "../Persistence"),
        .package(path: "../Service")
    ],
    targets: [
        .target(name: "Notifications", dependencies: ["Model", "Persistence", "Service"]),
        .testTarget(name: "NotificationsTests", dependencies: ["Notifications"])
    ]
)
