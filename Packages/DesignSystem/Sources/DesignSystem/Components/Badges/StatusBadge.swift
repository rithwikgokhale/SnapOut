import SwiftUI

public struct StatusBadge: View {

    private let text: String
    private let variant: Variant

    public enum Variant {
        case success
        case warning
        case error
        case neutral

        var foreground: Color {
            switch self {
            case .success: return AppColor.success
            case .warning: return AppColor.warning
            case .error: return AppColor.error
            case .neutral: return AppColor.textSecondary
            }
        }

        var background: Color {
            switch self {
            case .success: return AppColor.success.opacity(0.12)
            case .warning: return AppColor.warning.opacity(0.12)
            case .error: return AppColor.error.opacity(0.12)
            case .neutral: return AppColor.surfaceSecondary
            }
        }
    }

    public init(_ text: String, variant: Variant) {
        self.text = text
        self.variant = variant
    }

    public var body: some View {
        Text(text)
            .font(AppText.caption)
            .foregroundStyle(variant.foreground)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(variant.background, in: Capsule())
    }
}

#Preview {
    HStack(spacing: AppSpacing.sm) {
        StatusBadge("Healthy", variant: .success)
        StatusBadge("Warning", variant: .warning)
        StatusBadge("Error", variant: .error)
        StatusBadge("Unknown", variant: .neutral)
    }
    .padding()
}
