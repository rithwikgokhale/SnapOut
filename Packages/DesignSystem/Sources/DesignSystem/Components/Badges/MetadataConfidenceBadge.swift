import SwiftUI

public struct MetadataConfidenceBadge: View {

    private let level: Level

    public enum Level: String, CaseIterable {
        case high = "High"
        case medium = "Medium"
        case low = "Low"

        var color: Color {
            switch self {
            case .high: return AppColor.success
            case .medium: return AppColor.warning
            case .low: return AppColor.error
            }
        }

        var icon: String {
            switch self {
            case .high: return "checkmark.seal.fill"
            case .medium: return "exclamationmark.circle.fill"
            case .low: return "questionmark.circle.fill"
            }
        }
    }

    public init(level: Level) {
        self.level = level
    }

    public var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: level.icon)
                .font(.caption2)
            Text(level.rawValue)
                .font(AppText.caption)
        }
        .foregroundStyle(level.color)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(level.color.opacity(0.12), in: Capsule())
    }
}

#Preview {
    HStack(spacing: AppSpacing.sm) {
        MetadataConfidenceBadge(level: .high)
        MetadataConfidenceBadge(level: .medium)
        MetadataConfidenceBadge(level: .low)
    }
    .padding()
}
