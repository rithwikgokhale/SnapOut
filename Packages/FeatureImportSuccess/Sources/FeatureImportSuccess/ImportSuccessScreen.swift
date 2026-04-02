import SwiftUI
import DesignSystem

public struct ImportSuccessScreen: View {

    private let importedCount: Int
    private let skippedCount: Int
    private let failureCount: Int
    private let duplicateCount: Int
    private let albumName: String
    private let onDone: () -> Void
    private let onViewFailures: () -> Void
    private let onReviewDuplicates: () -> Void

    public init(
        importedCount: Int = 0,
        skippedCount: Int = 0,
        failureCount: Int = 0,
        duplicateCount: Int = 0,
        albumName: String = "Snapchat Memories",
        onDone: @escaping () -> Void = {},
        onViewFailures: @escaping () -> Void = {},
        onReviewDuplicates: @escaping () -> Void = {}
    ) {
        self.importedCount = importedCount
        self.skippedCount = skippedCount
        self.failureCount = failureCount
        self.duplicateCount = duplicateCount
        self.albumName = albumName
        self.onDone = onDone
        self.onViewFailures = onViewFailures
        self.onReviewDuplicates = onReviewDuplicates
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 56, weight: .light))
                            .foregroundStyle(AppColor.success)

                        Text("Import Complete")
                            .font(AppText.largeTitle)
                            .foregroundStyle(AppColor.textPrimary)

                        Text("Your memories have been added to \"\(albumName)\"")
                            .font(AppText.subheadline)
                            .foregroundStyle(AppColor.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, AppSpacing.xxxl)
                    .padding(.horizontal, AppSpacing.lg)

                    HStack(spacing: AppSpacing.md) {
                        StatCard(label: "Imported", value: "\(importedCount)", icon: "checkmark.circle")
                        StatCard(label: "Skipped", value: "\(skippedCount)", icon: "forward")
                    }
                    .padding(.horizontal, AppSpacing.lg)

                    if failureCount > 0 || duplicateCount > 0 {
                        HStack(spacing: AppSpacing.md) {
                            if failureCount > 0 {
                                StatCard(label: "Failed", value: "\(failureCount)", icon: "exclamationmark.triangle")
                            }
                            if duplicateCount > 0 {
                                StatCard(label: "Duplicates", value: "\(duplicateCount)", icon: "doc.on.doc")
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }

                    if failureCount > 0 {
                        SectionCard {
                            VStack(spacing: AppSpacing.md) {
                                IssueCard(
                                    severity: .warning,
                                    message: "\(failureCount) item(s) could not be imported",
                                    detail: "Tap below to view details"
                                )
                                SecondaryButton("View Failures", icon: "exclamationmark.triangle") {
                                    onViewFailures()
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }

                    if duplicateCount > 0 {
                        SectionCard {
                            VStack(spacing: AppSpacing.md) {
                                InfoRow(
                                    label: "Duplicates to review",
                                    value: "\(duplicateCount)",
                                    icon: "doc.on.doc"
                                )
                                SecondaryButton("Review Duplicates", icon: "doc.on.doc") {
                                    onReviewDuplicates()
                                }
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)
                    }
                }
                .padding(.bottom, AppSpacing.xxxl)
            }

            BottomActionBar(label: "Done", icon: "checkmark") {
                onDone()
            }
        }
    }
}

#Preview("Clean Import") {
    ImportSuccessScreen(importedCount: 1234, skippedCount: 0, failureCount: 0, duplicateCount: 0)
}

#Preview("With Issues") {
    ImportSuccessScreen(importedCount: 1180, skippedCount: 12, failureCount: 3, duplicateCount: 39)
}
