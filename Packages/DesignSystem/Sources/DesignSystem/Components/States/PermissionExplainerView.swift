import SwiftUI

public struct PermissionExplainerView: View {

    private let icon: String
    private let title: String
    private let reasons: [String]
    private let actionLabel: String
    private let action: () -> Void

    public init(
        icon: String,
        title: String,
        reasons: [String],
        actionLabel: String = "Continue",
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.reasons = reasons
        self.actionLabel = actionLabel
        self.action = action
    }

    public var body: some View {
        VStack(spacing: AppSpacing.xxl) {
            VStack(spacing: AppSpacing.lg) {
                Image(systemName: icon)
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(AppColor.accent)

                Text(title)
                    .font(AppText.title)
                    .foregroundStyle(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
            }

            VStack(alignment: .leading, spacing: AppSpacing.md) {
                ForEach(Array(reasons.enumerated()), id: \.offset) { _, reason in
                    HStack(alignment: .top, spacing: AppSpacing.md) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.body)
                            .foregroundStyle(AppColor.success)
                            .frame(width: 24, height: 24)

                        Text(reason)
                            .font(AppText.subheadline)
                            .foregroundStyle(AppColor.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.lg)

            PrimaryButton(actionLabel, action: action)
                .padding(.horizontal, AppSpacing.lg)
        }
        .padding(AppSpacing.xxxl)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    PermissionExplainerView(
        icon: "photo.on.rectangle",
        title: "Photo Library Access",
        reasons: [
            "Scan for duplicates and similar photos",
            "Analyze metadata to find issues",
            "All processing stays on your device"
        ],
        actionLabel: "Grant Access"
    ) {}
}
