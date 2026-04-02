// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DomainModels",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "DomainModels", targets: ["DomainModels"]),
    ],
    targets: [
        .target(name: "DomainModels"),
        .testTarget(name: "DomainModelsTests", dependencies: ["DomainModels"]),
    ]
)
