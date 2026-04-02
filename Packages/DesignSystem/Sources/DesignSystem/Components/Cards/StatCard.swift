import SwiftUI

public struct StatCard: View {

    private let label: String
    private let value: String
    private let icon: String?

    public init(label: String, value: String, icon: String? = nil) {
        self.label = label
        self.value = value
        self.icon = icon
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack(spacing: AppSpacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(AppText.caption)
                        .foregroundStyle(AppColor.textTertiary)
                }
                Text(label)
                    .font(AppText.caption)
                    .foregroundStyle(AppColor.textTertiary)
            }

            Text(value)
                .font(AppText.largeTitle)
                .foregroundStyle(AppColor.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(AppSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColor.surfacePrimary, in: RoundedRectangle(cornerRadius: AppRadius.large))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.large)
                .strokeBorder(AppColor.borderSubtle, lineWidth: 0.5)
        )
    }
}

#Preview {
    HStack(spacing: AppSpacing.md) {
        StatCard(label: "Photos", value: "1,234", icon: "photo")
        StatCard(label: "Videos", value: "89", icon: "video")
    }
    .padding()
}
