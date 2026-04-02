import SwiftUI
import DesignSystem
import DomainModels

public struct ExportHealthScreen: View {

    private let totalRecords: Int
    private let photoCount: Int
    private let videoCount: Int
    private let healthScore: Double
    private let issues: [HealthIssue]
    private let isScanning: Bool
    private let onContinue: () -> Void
    private let onCancel: () -> Void

    public struct HealthIssue: Identifiable {
        public let id = UUID()
        public let message: String
        public let detail: String?
        public let isError: Bool

        public init(message: String, detail: String? = nil, isError: Bool = false) {
            self.message = message
            self.detail = detail
            self.isError = isError
        }
    }

    public init(
        totalRecords: Int = 0,
        photoCount: Int = 0,
        videoCount: Int = 0,
        healthScore: Double = 0,
        issues: [HealthIssue] = [],
        isScanning: Bool = false,
        onContinue: @escaping () -> Void = {},
        onCancel: @escaping () -> Void = {}
    ) {
        self.totalRecords = totalRecords
        self.photoCount = photoCount
        self.videoCount = videoCount
        self.healthScore = healthScore
        self.issues = issues
        self.isScanning = isScanning
        self.onContinue = onContinue
        self.onCancel = onCancel
    }

    public var body: some View {
        VStack(spacing: 0) {
            if isScanning {
                Spacer()
                LoadingStateView(message: "Scanning export…")
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        ScreenHeader(
                            title: "Export Health",
                            subtitle: "Review your Snapchat export before importing"
                        )

                        HealthSummaryCard(
                            score: healthScore,
                            title: "Export Quality",
                            subtitle: issues.isEmpty ? "No issues found" : "\(issues.count) issue(s) found"
                        )
                        .padding(.horizontal, AppSpacing.lg)

                        HStack(spacing: AppSpacing.md) {
                            StatCard(label: "Photos", value: "\(photoCount)", icon: "photo")
                            StatCard(label: "Videos", value: "\(videoCount)", icon: "video")
                        }
                        .padding(.horizontal, AppSpacing.lg)

                        StatCard(label: "Total Records", value: "\(totalRecords)", icon: "doc.text")
                            .padding(.horizontal, AppSpacing.lg)

                        if !issues.isEmpty {
                            SectionCard(title: "Issues") {
                                VStack(spacing: AppSpacing.sm) {
                                    ForEach(issues) { issue in
                                        IssueCard(
                                            severity: issue.isError ? .error : .warning,
                                            message: issue.message,
                                            detail: issue.detail
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }
                    }
                    .padding(.bottom, AppSpacing.xxxl)
                }

                BottomActionBar(label: "Continue to Import", icon: "arrow.right") {
                    onContinue()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { onCancel() }
            }
        }
    }
}

#Preview("Healthy") {
    NavigationStack {
        ExportHealthScreen(
            totalRecords: 1234,
            photoCount: 1100,
            videoCount: 134,
            healthScore: 0.92,
            issues: []
        )
    }
}

#Preview("With Issues") {
    NavigationStack {
        ExportHealthScreen(
            totalRecords: 1234,
            photoCount: 1100,
            videoCount: 134,
            healthScore: 0.68,
            issues: [
                .init(message: "42 records have no timestamp", detail: "These will use file modification date"),
                .init(message: "3 files could not be read", detail: "Permission or corruption issue", isError: true),
            ]
        )
    }
}

#Preview("Scanning") {
    ExportHealthScreen(isScanning: true)
}
