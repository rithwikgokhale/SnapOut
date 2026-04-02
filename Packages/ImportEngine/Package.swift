// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ImportEngine",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ImportEngine", targets: ["ImportEngine"]),
    ],
    dependencies: [
        .package(path: "../DomainModels"),
        .package(path: "../AppCore"),
    ],
    targets: [
        .target(
            name: "ImportEngine",
            dependencies: ["DomainModels", "AppCore"]
        ),
        .testTarget(name: "ImportEngineTests", dependencies: ["ImportEngine"]),
    ]
)
