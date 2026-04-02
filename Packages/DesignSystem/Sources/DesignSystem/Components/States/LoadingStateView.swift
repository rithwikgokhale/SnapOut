import SwiftUI

public struct LoadingStateView: View {

    private let message: String?

    public init(message: String? = nil) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: AppSpacing.lg) {
            ProgressView()
                .controlSize(.large)

            if let message {
                Text(message)
                    .font(AppText.subheadline)
                    .foregroundStyle(AppColor.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppSpacing.xxxl)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    LoadingStateView(message: "Scanning your library…")
}
