// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeatureImportSuccess",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "FeatureImportSuccess", targets: ["FeatureImportSuccess"]),
    ],
    dependencies: [
        .package(path: "../DomainModels"),
        .package(path: "../AppCore"),
        .package(path: "../DesignSystem"),
    ],
    targets: [
        .target(
            name: "FeatureImportSuccess",
            dependencies: ["DomainModels", "AppCore", "DesignSystem"]
        ),
        .testTarget(name: "FeatureImportSuccessTests", dependencies: ["FeatureImportSuccess"]),
    ]
)
