// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeatureExportHealth",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "FeatureExportHealth", targets: ["FeatureExportHealth"]),
    ],
    dependencies: [
        .package(path: "../DomainModels"),
        .package(path: "../AppCore"),
        .package(path: "../DesignSystem"),
    ],
    targets: [
        .target(
            name: "FeatureExportHealth",
            dependencies: ["DomainModels", "AppCore", "DesignSystem"]
        ),
        .testTarget(name: "FeatureExportHealthTests", dependencies: ["FeatureExportHealth"]),
    ]
)
