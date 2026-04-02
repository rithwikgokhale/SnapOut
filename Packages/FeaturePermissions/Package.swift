// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeaturePermissions",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "FeaturePermissions", targets: ["FeaturePermissions"]),
    ],
    dependencies: [
        .package(path: "../DomainModels"),
        .package(path: "../AppCore"),
        .package(path: "../DesignSystem"),
    ],
    targets: [
        .target(
            name: "FeaturePermissions",
            dependencies: ["DomainModels", "AppCore", "DesignSystem"]
        ),
        .testTarget(name: "FeaturePermissionsTests", dependencies: ["FeaturePermissions"]),
    ]
)
