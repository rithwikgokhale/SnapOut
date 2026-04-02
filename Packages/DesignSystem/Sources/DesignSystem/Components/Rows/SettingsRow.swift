import SwiftUI

public struct SettingsRow<Trailing: View>: View {

    private let label: String
    private let icon: String?
    private let iconColor: Color
    private let trailing: Trailing

    public init(
        label: String,
        icon: String? = nil,
        iconColor: Color = AppColor.accent,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.label = label
        self.icon = icon
        self.iconColor = iconColor
        self.trailing = trailing()
    }

    public var body: some View {
        HStack(spacing: AppSpacing.md) {
            if let icon {
                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(iconColor)
                    .frame(width: 28, height: 28)
                    .background(iconColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 6))
            }

            Text(label)
                .font(AppText.body)
                .foregroundStyle(AppColor.textPrimary)

            Spacer(minLength: AppSpacing.sm)

            trailing
        }
        .padding(.vertical, AppSpacing.sm)
        .contentShape(Rectangle())
    }
}

// MARK: - Convenience initializers

public extension SettingsRow where Trailing == Image {
    /// Navigation-style row with a chevron
    init(
        label: String,
        icon: String? = nil,
        iconColor: Color = AppColor.accent
    ) {
        self.init(label: label, icon: icon, iconColor: iconColor) {
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColor.textTertiary)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        SettingsRow(label: "Notifications", icon: "bell.fill")
        Divider()
        SettingsRow(label: "Auto-Scan", icon: "arrow.triangle.2.circlepath") {
            Toggle("", isOn: .constant(true))
                .labelsHidden()
        }
        Divider()
        SettingsRow(label: "Storage", icon: "internaldrive.fill") {
            Text("24.1 GB")
                .font(AppText.subheadline)
                .foregroundStyle(AppColor.textSecondary)
        }
    }
    .padding()
}
