// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DedupeEngine",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "DedupeEngine", targets: ["DedupeEngine"]),
    ],
    dependencies: [
        .package(path: "../DomainModels"),
        .package(path: "../AppCore"),
    ],
    targets: [
        .target(
            name: "DedupeEngine",
            dependencies: ["DomainModels", "AppCore"]
        ),
        .testTarget(name: "DedupeEngineTests", dependencies: ["DedupeEngine"]),
    ]
)
