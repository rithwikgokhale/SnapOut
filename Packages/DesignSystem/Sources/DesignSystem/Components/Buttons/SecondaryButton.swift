import SwiftUI

public struct SecondaryButton: View {

    private let label: String
    private let icon: String?
    private let action: () -> Void

    public init(
        _ label: String,
        icon: String? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.body.weight(.medium))
                }
                Text(label)
                    .font(AppText.bodyEmphasis)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .foregroundStyle(AppColor.accent)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.medium)
                    .strokeBorder(AppColor.accent, lineWidth: 1.5)
            )
        }
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        SecondaryButton("Cancel") {}
        SecondaryButton("Settings", icon: "gearshape") {}
    }
    .padding()
}
