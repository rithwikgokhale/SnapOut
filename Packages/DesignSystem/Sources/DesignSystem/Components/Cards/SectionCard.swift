import SwiftUI

public struct SectionCard<Content: View>: View {

    private let title: String?
    private let content: Content

    public init(
        title: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            if let title {
                Text(title)
                    .font(AppText.sectionHeader)
                    .foregroundStyle(AppColor.textPrimary)
            }
            content
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
    SectionCard(title: "Details") {
        Text("Card content goes here")
            .font(AppText.body)
            .foregroundStyle(AppColor.textSecondary)
    }
    .padding()
}
