import SwiftUI

public struct PrimaryButton: View {

    private let label: String
    private let icon: String?
    private let isLoading: Bool
    private let action: () -> Void

    public init(
        _ label: String,
        icon: String? = nil,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.body.weight(.semibold))
                    }
                    Text(label)
                        .font(AppText.bodyEmphasis)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .foregroundStyle(.white)
            .background(AppColor.accent, in: RoundedRectangle(cornerRadius: AppRadius.medium))
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.8 : 1)
    }
}

#Preview {
    VStack(spacing: AppSpacing.lg) {
        PrimaryButton("Continue", icon: "arrow.right") {}
        PrimaryButton("Loading…", isLoading: true) {}
    }
    .padding()
}
