import SwiftUI

public struct EmptyStateView: View {

    private let icon: String
    private let title: String
    private let subtitle: String?

    public init(icon: String, title: String, subtitle: String? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(AppColor.textTertiary)

            VStack(spacing: AppSpacing.sm) {
                Text(title)
                    .font(AppText.title)
                    .foregroundStyle(AppColor.textPrimary)
                    .multilineTextAlignment(.center)

                if let subtitle {
                    Text(subtitle)
                        .font(AppText.subheadline)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(AppSpacing.xxxl)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView(
        icon: "photo.on.rectangle.angled",
        title: "No Photos Yet",
        subtitle: "Grant access to your photo library to get started."
    )
}
