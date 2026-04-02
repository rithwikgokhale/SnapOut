import SwiftUI

public struct BottomActionBar: View {

    private let label: String
    private let icon: String?
    private let isLoading: Bool
    private let action: () -> Void

    public init(
        label: String,
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
        VStack(spacing: 0) {
            Divider()
            PrimaryButton(label, icon: icon, isLoading: isLoading, action: action)
                .padding(.horizontal, AppSpacing.lg)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.sm)
        }
        .background(.ultraThinMaterial)
    }
}

#Preview {
    VStack {
        Spacer()
        BottomActionBar(label: "Start Scan", icon: "magnifyingglass") {}
    }
}
