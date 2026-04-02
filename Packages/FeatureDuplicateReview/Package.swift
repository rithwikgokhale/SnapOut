// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FeatureDuplicateReview",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "FeatureDuplicateReview", targets: ["FeatureDuplicateReview"]),
    ],
    dependencies: [
        .package(path: "../DomainModels"),
        .package(path: "../AppCore"),
        .package(path: "../DesignSystem"),
    ],
    targets: [
        .target(
            name: "FeatureDuplicateReview",
            dependencies: ["DomainModels", "AppCore", "DesignSystem"]
        ),
        .testTarget(name: "FeatureDuplicateReviewTests", dependencies: ["FeatureDuplicateReview"]),
    ]
)
