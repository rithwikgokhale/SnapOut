import SwiftUI
import DesignSystem
import AppCore
import DomainModels

public struct WelcomeScreen: View {
    var hasActiveSession: Bool
    var onGetStarted: () -> Void
    var onResumeSession: () -> Void

    public init(
        hasActiveSession: Bool = false,
        onGetStarted: @escaping () -> Void = {},
        onResumeSession: @escaping () -> Void = {}
    ) {
        self.hasActiveSession = hasActiveSession
        self.onGetStarted = onGetStarted
        self.onResumeSession = onResumeSession
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    ScreenHeader(
                        title: "SnapOut",
                        subtitle: "Import your Snapchat Memories safely"
                    )

                    SectionCard(title: "How It Works") {
                        VStack(spacing: AppSpacing.sm) {
                            InfoRow(
                                label: "No Snapchat login needed",
                                value: "",
                                icon: "person.badge.shield.checkmark"
                            )
                            InfoRow(
                                label: "No cloud uploads",
                                value: "",
                                icon: "icloud.slash"
                            )
                            InfoRow(
                                label: "Everything stays on your device",
                                value: "",
                                icon: "lock.shield"
                            )
                            InfoRow(
                                label: "Full library duplicate detection",
                                value: "",
                                icon: "doc.on.doc"
                            )
                        }
                    }

                    if hasActiveSession {
                        SectionCard {
                            VStack(spacing: AppSpacing.md) {
                                Text("Resume Previous Import")
                                    .font(AppText.body)
                                    .foregroundStyle(AppColor.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                SecondaryButton("Resume Session", icon: "arrow.clockwise") {
                                    onResumeSession()
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, AppSpacing.xxxl)
            }

            BottomActionBar(label: "Get Started", icon: "arrow.right") {
                onGetStarted()
            }
        }
    }
}

#Preview {
    WelcomeScreen(hasActiveSession: false)
}

#Preview("With Active Session") {
    WelcomeScreen(hasActiveSession: true)
}
