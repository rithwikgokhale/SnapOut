import SwiftUI
import DesignSystem
import DomainModels

public struct DuplicateReviewScreen: View {

    private let candidates: [DuplicateDisplayItem]
    private let onKeep: (UUID) -> Void
    private let onSkip: (UUID) -> Void
    private let onDone: () -> Void

    public struct DuplicateDisplayItem: Identifiable {
        public let id: UUID
        public let importFileName: String
        public let libraryAssetIdentifier: String
        public let confidence: DuplicateConfidence
        public let reasonDescription: String
        public let isResolved: Bool

        public init(
            id: UUID = UUID(),
            importFileName: String = "",
            libraryAssetIdentifier: String = "",
            confidence: DuplicateConfidence = .suspected,
            reasonDescription: String = "",
            isResolved: Bool = false
        ) {
            self.id = id
            self.importFileName = importFileName
            self.libraryAssetIdentifier = libraryAssetIdentifier
            self.confidence = confidence
            self.reasonDescription = reasonDescription
            self.isResolved = isResolved
        }
    }

    public init(
        candidates: [DuplicateDisplayItem] = [],
        onKeep: @escaping (UUID) -> Void = { _ in },
        onSkip: @escaping (UUID) -> Void = { _ in },
        onDone: @escaping () -> Void = {}
    ) {
        self.candidates = candidates
        self.onKeep = onKeep
        self.onSkip = onSkip
        self.onDone = onDone
    }

    public var body: some View {
        VStack(spacing: 0) {
            if candidates.isEmpty {
                Spacer()
                EmptyStateView(
                    icon: "checkmark.seal",
                    title: "No Duplicates Found",
                    subtitle: "All imported memories appear to be unique."
                )
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: AppSpacing.lg) {
                        ScreenHeader(
                            title: "Duplicate Review",
                            subtitle: "\(unresolvedCount) item(s) need your decision"
                        )

                        SectionCard {
                            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                InfoRow(
                                    label: "Total candidates",
                                    value: "\(candidates.count)",
                                    icon: "doc.on.doc"
                                )
                                InfoRow(
                                    label: "Reviewed",
                                    value: "\(resolvedCount)",
                                    icon: "checkmark.circle"
                                )
                            }
                        }
                        .padding(.horizontal, AppSpacing.lg)

                        ForEach(candidates) { item in
                            candidateCard(item)
                                .padding(.horizontal, AppSpacing.lg)
                        }
                    }
                    .padding(.bottom, AppSpacing.xxxl)
                }
            }

            BottomActionBar(label: "Done", icon: "checkmark") {
                onDone()
            }
        }
    }

    private func candidateCard(_ item: DuplicateDisplayItem) -> some View {
        SectionCard {
            VStack(spacing: AppSpacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text(item.importFileName.isEmpty ? "Imported File" : item.importFileName)
                            .font(AppText.bodyEmphasis)
                            .foregroundStyle(AppColor.textPrimary)
                        Text(item.reasonDescription.isEmpty ? "Potential duplicate detected" : item.reasonDescription)
                            .font(AppText.footnote)
                            .foregroundStyle(AppColor.textSecondary)
                    }
                    Spacer()
                    confidenceBadge(item.confidence)
                }

                if item.isResolved {
                    StatusBadge("Resolved", variant: .success)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                } else {
                    HStack(spacing: AppSpacing.md) {
                        SecondaryButton("Keep Both", icon: "plus.square.on.square") {
                            onKeep(item.id)
                        }
                        SecondaryButton("Skip Import", icon: "minus.circle") {
                            onSkip(item.id)
                        }
                    }
                }
            }
        }
    }

    private func confidenceBadge(_ confidence: DuplicateConfidence) -> some View {
        switch confidence {
        case .confirmed:
            return StatusBadge("Confirmed", variant: .error)
        case .suspected:
            return StatusBadge("Suspected", variant: .warning)
        }
    }

    private var resolvedCount: Int {
        candidates.filter(\.isResolved).count
    }

    private var unresolvedCount: Int {
        candidates.count - resolvedCount
    }
}

#Preview("With Candidates") {
    DuplicateReviewScreen(candidates: [
        .init(importFileName: "IMG_2024_01.jpg", confidence: .confirmed, reasonDescription: "Files are byte-identical"),
        .init(importFileName: "VID_2024_03.mp4", confidence: .suspected, reasonDescription: "Same dimensions and creation date"),
        .init(importFileName: "IMG_2024_05.jpg", confidence: .confirmed, reasonDescription: "Files are byte-identical", isResolved: true),
    ])
}

#Preview("Empty") {
    DuplicateReviewScreen()
}
