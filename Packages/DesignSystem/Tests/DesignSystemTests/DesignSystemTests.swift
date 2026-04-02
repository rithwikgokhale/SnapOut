import XCTest
@testable import DesignSystem

final class DesignSystemTests: XCTestCase {

    func testTokensExist() {
        // Verify color tokens are accessible
        _ = AppColor.accent
        _ = AppColor.backgroundPrimary
        _ = AppColor.textPrimary

        // Verify spacing tokens
        XCTAssertEqual(AppSpacing.xs, 4)
        XCTAssertEqual(AppSpacing.sm, 8)
        XCTAssertEqual(AppSpacing.md, 12)
        XCTAssertEqual(AppSpacing.lg, 16)
        XCTAssertEqual(AppSpacing.xl, 20)
        XCTAssertEqual(AppSpacing.xxl, 24)
        XCTAssertEqual(AppSpacing.xxxl, 32)

        // Verify radius tokens
        XCTAssertEqual(AppRadius.small, 8)
        XCTAssertEqual(AppRadius.medium, 12)
        XCTAssertEqual(AppRadius.large, 16)
        XCTAssertEqual(AppRadius.xlarge, 20)

        // Verify text tokens are accessible
        _ = AppText.largeTitle
        _ = AppText.body
        _ = AppText.monospacedMeta
    }
}
