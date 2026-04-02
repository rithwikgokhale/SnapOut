import SwiftUI

public struct DestructiveButton: View {

    private let label: String
    private let icon: String?
    private let style: Style
    private let action: () -> Void

    public enum Style {
        case filled
        case bordered
    }

    public init(
        _ label: String,
        icon: String? = nil,
        style: Style = .filled,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.style = style
        self.action = action
    }

    public var body: some View {
        Button(role: .destructive, action: action) {
            HStack(spacing: AppSpacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                }
                Text(label)
                    .font(AppText.bodyEmphasis)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .foregroundStyle(style == .filled ? .white : AppColor.error)
            .background {
                switch style {
                case .filled:
                    RoundedRectangle(cornerRadius: AppRadius.medium)
                        .fill(AppColor.error)
                case .bordered:
                    RoundedRectangle(cornerRadius: AppRadius.medium)
                        .strokeBorder(AppColor.error, lineWidth: 1.5)
                }
            }
        }
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        DestructiveButton("Delete All", icon: "trash", style: .filled) {}
        DestructiveButton("Remove", icon: "minus.circle", style: .bordered) {}
    }
    .padding()
}
