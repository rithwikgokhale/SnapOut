import SwiftUI
import DesignSystem
import DomainModels

public struct ImportProgressScreen: View {

    private let phase: ImportPhase
    private let progress: Double
    private let processedCount: Int
    private let totalCount: Int
    private let failureCount: Int
    private let elapsedSeconds: Int
    private let onCancel: () -> Void

    public init(
        phase: ImportPhase = .idle,
        progress: Double = 0,
        processedCount: Int = 0,
        totalCount: Int = 0,
        failureCount: Int = 0,
        elapsedSeconds: Int = 0,
        onCancel: @escaping () -> Void = {}
    ) {
        self.phase = phase
        self.progress = progress
        self.processedCount = processedCount
        self.totalCount = totalCount
        self.failureCount = failureCount
        self.elapsedSeconds = elapsedSeconds
        self.onCancel = onCancel
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    ScreenHeader(
                        title: "Importing",
                        subtitle: phaseDescription
                    )

                    ProgressCard(
                        phase: phaseLabel,
                        progress: progress,
                        detail: "\(processedCount) of \(totalCount) items"
                    )
                    .padding(.horizontal, AppSpacing.lg)

                    HStack(spacing: AppSpacing.md) {
                        StatCard(label: "Imported", value: "\(processedCount)", icon: "checkmark.circle")
                        StatCard(label: "Failed", value: "\(failureCount)", icon: "exclamationmark.triangle")
                    }
                    .padding(.horizontal, AppSpacing.lg)

                    StatCard(label: "Elapsed", value: formattedElapsed, icon: "clock")
                        .padding(.horizontal, AppSpacing.lg)

                    SectionCard {
                        VStack(spacing: AppSpacing.sm) {
                            InfoRow(label: "Phase", value: phaseLabel, icon: "gearshape.2")
                            InfoRow(label: "Remaining", value: "\(max(0, totalCount - processedCount))", icon: "tray")
                        }
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
                .padding(.bottom, AppSpacing.xxxl)
            }

            VStack(spacing: 0) {
                Divider()
                SecondaryButton("Cancel Import", icon: "xmark") {
                    onCancel()
                }
                .padding(.horizontal, AppSpacing.lg)
                .padding(.vertical, AppSpacing.md)
            }
            .background(.ultraThinMaterial)
        }
        .interactiveDismissDisabled()
    }

    private var phaseLabel: String {
        switch phase {
        case .idle: return "Preparing"
        case .sourceIntake: return "Reading Source"
        case .scanning: return "Scanning"
        case .parsing: return "Parsing"
        case .healthReport: return "Health Check"
        case .planning: return "Planning"
        case .deduplication: return "Deduplication"
        case .importing: return "Importing"
        case .review: return "Review"
        case .completion: return "Finishing"
        case .cleanup: return "Cleaning Up"
        }
    }

    private var phaseDescription: String {
        switch phase {
        case .importing: return "Writing memories to your photo library"
        case .scanning: return "Scanning your export files"
        case .deduplication: return "Checking for duplicates in your library"
        default: return "Processing your Snapchat Memories"
        }
    }

    private var formattedElapsed: String {
        let minutes = elapsedSeconds / 60
        let seconds = elapsedSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    ImportProgressScreen(
        phase: .importing,
        progress: 0.42,
        processedCount: 521,
        totalCount: 1234,
        failureCount: 3,
        elapsedSeconds: 187
    )
}
