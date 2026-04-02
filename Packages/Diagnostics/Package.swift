// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Diagnostics",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Diagnostics", targets: ["Diagnostics"]),
    ],
    dependencies: [
        .package(path: "../DomainModels"),
    ],
    targets: [
        .target(name: "Diagnostics", dependencies: ["DomainModels"]),
        .testTarget(name: "DiagnosticsTests", dependencies: ["Diagnostics"]),
    ]
)
