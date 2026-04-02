import SwiftUI

public struct HealthSummaryCard: View {

    private let score: Double
    private let title: String
    private let subtitle: String?

    public init(score: Double, title: String = "Library Health", subtitle: String? = nil) {
        self.score = min(max(score, 0), 1)
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        HStack(spacing: AppSpacing.lg) {
            scoreIndicator
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(AppText.sectionHeader)
                    .foregroundStyle(AppColor.textPrimary)

                Text(scoreLabel)
                    .font(AppText.bodyEmphasis)
                    .foregroundStyle(scoreColor)

                if let subtitle {
                    Text(subtitle)
                        .font(AppText.footnote)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(AppSpacing.lg)
        .background(AppColor.surfacePrimary, in: RoundedRectangle(cornerRadius: AppRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.large)
                .strokeBorder(AppColor.borderSubtle, lineWidth: 0.5)
        )
    }

    private var scoreIndicator: some View {
        ZStack {
            Circle()
                .stroke(AppColor.borderSubtle, lineWidth: 4)
            Circle()
                .trim(from: 0, to: score)
                .stroke(scoreColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Text(formattedScore)
                .font(AppText.titleEmphasis)
                .foregroundStyle(scoreColor)
        }
        .frame(width: 64, height: 64)
    }

    private var scoreColor: Color {
        switch score {
        case 0.75...: return AppColor.success
        case 0.5..<0.75: return AppColor.warning
        default: return AppColor.error
        }
    }

    private var scoreLabel: String {
        switch score {
        case 0.75...: return "Good"
        case 0.5..<0.75: return "Fair"
        default: return "Needs Attention"
        }
    }

    private var formattedScore: String {
        "\(Int(score * 100))"
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        HealthSummaryCard(score: 0.85, subtitle: "12 issues found")
        HealthSummaryCard(score: 0.55, subtitle: "28 issues found")
        HealthSummaryCard(score: 0.30, subtitle: "67 issues found")
    }
    .padding()
}
