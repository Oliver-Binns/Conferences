// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Persistence",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "Persistence", targets: ["Persistence"]),
    ],
    targets: [
        .target(name: "Persistence",
                swiftSettings: [.define("DEBUG", .when(configuration: .debug))]),
        .testTarget(name: "PersistenceTests", dependencies: ["Persistence"]),
    ]
)
