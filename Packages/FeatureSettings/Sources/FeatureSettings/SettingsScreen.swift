import SwiftUI
import DesignSystem

public struct SettingsScreen: View {

    private let appVersion: String
    private let onViewDiagnostics: () -> Void
    private let onExportDiagnostics: () -> Void
    private let onResetData: () -> Void

    public init(
        appVersion: String = "1.0.0",
        onViewDiagnostics: @escaping () -> Void = {},
        onExportDiagnostics: @escaping () -> Void = {},
        onResetData: @escaping () -> Void = {}
    ) {
        self.appVersion = appVersion
        self.onViewDiagnostics = onViewDiagnostics
        self.onExportDiagnostics = onExportDiagnostics
        self.onResetData = onResetData
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                ScreenHeader(title: "Settings")

                SectionCard(title: "Diagnostics") {
                    VStack(spacing: 0) {
                        Button { onViewDiagnostics() } label: {
                            SettingsRow(
                                label: "View Diagnostic Logs",
                                icon: "doc.text.magnifyingglass",
                                iconColor: AppColor.accent
                            )
                        }
                        .buttonStyle(.plain)

                        Divider()

                        Button { onExportDiagnostics() } label: {
                            SettingsRow(
                                label: "Export Diagnostic Bundle",
                                icon: "square.and.arrow.up",
                                iconColor: AppColor.accent
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)

                SectionCard(title: "Data") {
                    VStack(spacing: 0) {
                        Button { onResetData() } label: {
                            SettingsRow(
                                label: "Reset All Data",
                                icon: "trash",
                                iconColor: AppColor.error
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)

                SectionCard(title: "About") {
                    VStack(spacing: AppSpacing.sm) {
                        InfoRow(label: "Version", value: appVersion, icon: "info.circle")
                        InfoRow(label: "Privacy", value: "On-device only", icon: "lock.shield")
                        InfoRow(label: "Data stored", value: "Local database", icon: "internaldrive")
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
            .padding(.bottom, AppSpacing.xxxl)
        }
    }
}

#Preview {
    SettingsScreen()
}
