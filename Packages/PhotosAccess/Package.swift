// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PhotosAccess",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "PhotosAccess", targets: ["PhotosAccess"]),
    ],
    dependencies: [
        .package(path: "../DomainModels"),
        .package(path: "../AppCore"),
    ],
    targets: [
        .target(
            name: "PhotosAccess",
            dependencies: ["DomainModels", "AppCore"]
        ),
        .testTarget(name: "PhotosAccessTests", dependencies: ["PhotosAccess"]),
    ]
)
