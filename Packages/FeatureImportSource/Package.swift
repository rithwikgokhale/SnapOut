// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeatureImportSource",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "FeatureImportSource", targets: ["FeatureImportSource"]),
    ],
    dependencies: [
        .package(path: "../DomainModels"),
        .package(path: "../AppCore"),
        .package(path: "../DesignSystem"),
    ],
    targets: [
        .target(
            name: "FeatureImportSource",
            dependencies: ["DomainModels", "AppCore", "DesignSystem"]
        ),
        .testTarget(name: "FeatureImportSourceTests", dependencies: ["FeatureImportSource"]),
    ]
)
