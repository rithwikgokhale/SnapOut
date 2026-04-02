import SwiftUI

public struct ProgressCard: View {

    private let phase: String
    private let progress: Double
    private let detail: String?

    public init(phase: String, progress: Double, detail: String? = nil) {
        self.phase = phase
        self.progress = min(max(progress, 0), 1)
        self.detail = detail
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            HStack {
                Text(phase)
                    .font(AppText.sectionHeader)
                    .foregroundStyle(AppColor.textPrimary)
                Spacer()
                Text(percentLabel)
                    .font(AppText.monospacedMeta)
                    .foregroundStyle(AppColor.textSecondary)
            }

            ProgressView(value: progress)
                .tint(AppColor.accent)

            if let detail {
                Text(detail)
                    .font(AppText.footnote)
                    .foregroundStyle(AppColor.textTertiary)
            }
        }
        .padding(AppSpacing.lg)
        .background(AppColor.surfacePrimary, in: RoundedRectangle(cornerRadius: AppRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.large)
                .strokeBorder(AppColor.borderSubtle, lineWidth: 0.5)
        )
    }

    private var percentLabel: String {
        "\(Int(progress * 100))%"
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        ProgressCard(phase: "Scanning Photos", progress: 0.45, detail: "562 of 1,234 items")
        ProgressCard(phase: "Complete", progress: 1.0)
    }
    .padding()
}
