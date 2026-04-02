// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeatureSettings",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "FeatureSettings", targets: ["FeatureSettings"]),
    ],
    dependencies: [
        .package(path: "../DomainModels"),
        .package(path: "../AppCore"),
        .package(path: "../DesignSystem"),
    ],
    targets: [
        .target(
            name: "FeatureSettings",
            dependencies: ["DomainModels", "AppCore", "DesignSystem"]
        ),
        .testTarget(name: "FeatureSettingsTests", dependencies: ["FeatureSettings"]),
    ]
)
