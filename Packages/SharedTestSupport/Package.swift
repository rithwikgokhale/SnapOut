// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SharedTestSupport",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "SharedTestSupport", targets: ["SharedTestSupport"]),
    ],
    dependencies: [
        .package(path: "../DomainModels"),
        .package(path: "../AppCore"),
    ],
    targets: [
        .target(name: "SharedTestSupport", dependencies: ["DomainModels", "AppCore"]),
    ]
)
