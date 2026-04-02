import SwiftUI

public struct ScreenHeader: View {

    private let title: String
    private let subtitle: String?

    public init(title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppText.largeTitle)
                .foregroundStyle(AppColor.textPrimary)

            if let subtitle {
                Text(subtitle)
                    .font(AppText.subheadline)
                    .foregroundStyle(AppColor.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.lg)
        .padding(.bottom, AppSpacing.sm)
    }
}

#Preview {
    ScreenHeader(
        title: "Library Health",
        subtitle: "Last scanned 2 hours ago"
    )
}
