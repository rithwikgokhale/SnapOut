import SwiftUI
import DesignSystem
import DomainModels

public struct ImportSourceScreen: View {

    private let onPickZIP: () -> Void
    private let onPickFolder: () -> Void

    public init(
        onPickZIP: @escaping () -> Void = {},
        onPickFolder: @escaping () -> Void = {}
    ) {
        self.onPickZIP = onPickZIP
        self.onPickFolder = onPickFolder
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                ScreenHeader(
                    title: "Choose Source",
                    subtitle: "Select your Snapchat Memories export"
                )

                SectionCard(title: "ZIP Archive") {
                    VStack(spacing: AppSpacing.md) {
                        InfoRow(
                            label: "Format",
                            value: "mydata.zip",
                            icon: "doc.zipper"
                        )
                        Text("Select the ZIP file you downloaded from Snapchat's data export.")
                            .font(AppText.footnote)
                            .foregroundStyle(AppColor.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        PrimaryButton("Select ZIP File", icon: "doc.zipper") {
                            onPickZIP()
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.lg)

                SectionCard(title: "Extracted Folder") {
                    VStack(spacing: AppSpacing.md) {
                        InfoRow(
                            label: "Format",
                            value: "Folder",
                            icon: "folder"
                        )
                        Text("If you already extracted the ZIP, select the top-level export folder.")
                            .font(AppText.footnote)
                            .foregroundStyle(AppColor.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        SecondaryButton("Select Folder", icon: "folder") {
                            onPickFolder()
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.lg)

                SectionCard(title: "Tips") {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        tipRow(icon: "arrow.down.circle", text: "Download your data from Snapchat → Settings → My Data")
                        tipRow(icon: "clock", text: "Large exports may take a few minutes to scan")
                        tipRow(icon: "lock.shield", text: "SnapOut reads files locally — nothing is uploaded")
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
            .padding(.bottom, AppSpacing.xxxl)
        }
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.sm) {
            Image(systemName: icon)
                .font(AppText.footnote)
                .foregroundStyle(AppColor.accent)
                .frame(width: 20)
            Text(text)
                .font(AppText.footnote)
                .foregroundStyle(AppColor.textSecondary)
        }
    }
}

#Preview {
    ImportSourceScreen()
}
