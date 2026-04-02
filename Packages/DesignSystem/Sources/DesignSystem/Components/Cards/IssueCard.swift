import SwiftUI

public struct IssueCard: View {

    private let severity: Severity
    private let message: String
    private let detail: String?

    public enum Severity {
        case warning
        case error

        var icon: String {
            switch self {
            case .warning: return "exclamationmark.triangle.fill"
            case .error: return "xmark.octagon.fill"
            }
        }

        var color: Color {
            switch self {
            case .warning: return AppColor.warning
            case .error: return AppColor.error
            }
        }
    }

    public init(severity: Severity, message: String, detail: String? = nil) {
        self.severity = severity
        self.message = message
        self.detail = detail
    }

    public var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Image(systemName: severity.icon)
                .font(.body)
                .foregroundStyle(severity.color)
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(message)
                    .font(AppText.bodyEmphasis)
                    .foregroundStyle(AppColor.textPrimary)

                if let detail {
                    Text(detail)
                        .font(AppText.footnote)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(AppSpacing.lg)
        .background(
            severity.color.opacity(0.08),
            in: RoundedRectangle(cornerRadius: AppRadius.medium)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.medium)
                .strokeBorder(severity.color.opacity(0.25), lineWidth: 0.5)
        )
    }
}

#Preview {
    VStack(spacing: AppSpacing.md) {
        IssueCard(severity: .warning, message: "12 photos have no location data", detail: "These items may not sort correctly")
        IssueCard(severity: .error, message: "Failed to read 3 files", detail: "Permission denied")
    }
    .padding()
}
