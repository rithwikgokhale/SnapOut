import SwiftUI

public struct InfoRow: View {

    private let label: String
    private let value: String
    private let icon: String?
    private let valueColor: Color

    public init(
        label: String,
        value: String,
        icon: String? = nil,
        valueColor: Color = AppColor.textPrimary
    ) {
        self.label = label
        self.value = value
        self.icon = icon
        self.valueColor = valueColor
    }

    public var body: some View {
        HStack(spacing: AppSpacing.sm) {
            if let icon {
                Image(systemName: icon)
                    .font(AppText.subheadline)
                    .foregroundStyle(AppColor.textTertiary)
                    .frame(width: 20)
            }

            Text(label)
                .font(AppText.subheadline)
                .foregroundStyle(AppColor.textSecondary)

            Spacer(minLength: AppSpacing.sm)

            Text(value)
                .font(AppText.body)
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, AppSpacing.sm)
    }
}

#Preview {
    VStack(spacing: 0) {
        InfoRow(label: "Format", value: "HEIC", icon: "doc")
        Divider()
        InfoRow(label: "Size", value: "2.4 MB", icon: "internaldrive")
        Divider()
        InfoRow(label: "Dimensions", value: "4032 × 3024", icon: "aspectratio")
    }
    .padding()
}
