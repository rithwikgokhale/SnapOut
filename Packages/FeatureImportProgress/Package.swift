// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeatureImportProgress",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "FeatureImportProgress", targets: ["FeatureImportProgress"]),
    ],
    dependencies: [
        .package(path: "../DomainModels"),
        .package(path: "../AppCore"),
        .package(path: "../DesignSystem"),
    ],
    targets: [
        .target(
            name: "FeatureImportProgress",
            dependencies: ["DomainModels", "AppCore", "DesignSystem"]
        ),
        .testTarget(name: "FeatureImportProgressTests", dependencies: ["FeatureImportProgress"]),
    ]
)
