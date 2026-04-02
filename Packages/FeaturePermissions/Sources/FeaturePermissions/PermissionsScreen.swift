import SwiftUI
import DesignSystem
import DomainModels

public struct PermissionsScreen: View {

    private let photosStatus: PermissionsState
    private let onRequestPhotosAccess: () -> Void
    private let onOpenSettings: () -> Void
    private let onContinue: () -> Void

    public init(
        photosStatus: PermissionsState = .notDetermined,
        onRequestPhotosAccess: @escaping () -> Void = {},
        onOpenSettings: @escaping () -> Void = {},
        onContinue: @escaping () -> Void = {}
    ) {
        self.photosStatus = photosStatus
        self.onRequestPhotosAccess = onRequestPhotosAccess
        self.onOpenSettings = onOpenSettings
        self.onContinue = onContinue
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    ScreenHeader(
                        title: "Permissions",
                        subtitle: "SnapOut needs access to your photo library"
                    )

                    PermissionExplainerView(
                        icon: "photo.on.rectangle.angled",
                        title: "Full Photo Library Access",
                        reasons: [
                            "Import Snapchat Memories into your library",
                            "Detect duplicates already in your library",
                            "Set correct dates and metadata",
                            "Everything stays on your device"
                        ],
                        actionLabel: actionLabel
                    ) {
                        handleAction()
                    }

                    if photosStatus == .denied {
                        IssueCard(
                            severity: .warning,
                            message: "Access was denied",
                            detail: "Open Settings to grant full photo library access."
                        )
                        .padding(.horizontal, AppSpacing.lg)
                    }

                    if photosStatus == .limited {
                        IssueCard(
                            severity: .warning,
                            message: "Limited access is not sufficient",
                            detail: "SnapOut requires full library access to detect duplicates and write metadata. Please grant full access in Settings."
                        )
                        .padding(.horizontal, AppSpacing.lg)
                    }
                }
                .padding(.bottom, AppSpacing.xxxl)
            }

            if photosStatus == .authorized {
                BottomActionBar(label: "Continue", icon: "arrow.right") {
                    onContinue()
                }
            }
        }
    }

    private var actionLabel: String {
        switch photosStatus {
        case .notDetermined: return "Grant Access"
        case .authorized: return "Access Granted"
        case .denied, .limited: return "Open Settings"
        }
    }

    private func handleAction() {
        switch photosStatus {
        case .notDetermined:
            onRequestPhotosAccess()
        case .denied, .limited:
            onOpenSettings()
        case .authorized:
            onContinue()
        }
    }
}

#Preview("Not Determined") {
    PermissionsScreen(photosStatus: .notDetermined)
}

#Preview("Authorized") {
    PermissionsScreen(photosStatus: .authorized)
}

#Preview("Denied") {
    PermissionsScreen(photosStatus: .denied)
}
