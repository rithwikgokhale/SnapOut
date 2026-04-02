// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ZipAccess",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "ZipAccess", targets: ["ZipAccess"]),
    ],
    dependencies: [
        .package(url: "https://github.com/weichsel/ZIPFoundation.git", from: "0.9.19"),
    ],
    targets: [
        .target(
            name: "ZipAccess",
            dependencies: ["ZIPFoundation"]
        ),
        .testTarget(name: "ZipAccessTests", dependencies: ["ZipAccess"]),
    ]
)
