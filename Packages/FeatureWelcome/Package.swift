// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeatureWelcome",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "FeatureWelcome", targets: ["FeatureWelcome"]),
    ],
    dependencies: [
        .package(path: "../DomainModels"),
        .package(path: "../AppCore"),
        .package(path: "../DesignSystem"),
    ],
    targets: [
        .target(
            name: "FeatureWelcome",
            dependencies: ["DomainModels", "AppCore", "DesignSystem"]
        ),
        .testTarget(name: "FeatureWelcomeTests", dependencies: ["FeatureWelcome"]),
    ]
)
