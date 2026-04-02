// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeatureImportOptions",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "FeatureImportOptions", targets: ["FeatureImportOptions"]),
    ],
    dependencies: [
        .package(path: "../DomainModels"),
        .package(path: "../AppCore"),
        .package(path: "../DesignSystem"),
    ],
    targets: [
        .target(
            name: "FeatureImportOptions",
            dependencies: ["DomainModels", "AppCore", "DesignSystem"]
        ),
        .testTarget(name: "FeatureImportOptionsTests", dependencies: ["FeatureImportOptions"]),
    ]
)
