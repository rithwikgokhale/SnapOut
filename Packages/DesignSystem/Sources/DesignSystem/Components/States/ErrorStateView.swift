import SwiftUI

public struct ErrorStateView: View {

    private let icon: String
    private let title: String
    private let message: String?
    private let retryAction: (() -> Void)?

    public init(
        icon: String = "exclamationmark.triangle",
        title: String = "Something went wrong",
        message: String? = nil,
        retryAction: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.retryAction = retryAction
    }

    public var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(AppColor.error)

            VStack(spacing: AppSpacing.sm) {
                Text(title)
                    .font(AppText.title)
                    .foregroundStyle(AppColor.textPrimary)
                    .multilineTextAlignment(.center)

                if let message {
                    Text(message)
                        .font(AppText.subheadline)
                        .foregroundStyle(AppColor.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }

            if let retryAction {
                SecondaryButton("Try Again", icon: "arrow.clockwise", action: retryAction)
                    .fixedSize(horizontal: true, vertical: false)
            }
        }
        .padding(AppSpacing.xxxl)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ErrorStateView(
        title: "Unable to Load",
        message: "Check your connection and try again.",
        retryAction: {}
    )
}
