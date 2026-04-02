import SwiftUI
import DomainModels
import FeatureWelcome
import FeaturePermissions
import FeatureImportSource
import FeatureExportHealth
import FeatureImportOptions
import FeatureImportProgress
import FeatureDuplicateReview
import FeatureImportSuccess
import FeatureSettings

// MARK: - Route

public enum AppRoute: Hashable {
    case welcome
    case permissions
    case importSource
    case exportHealth(sessionID: UUID)
    case importOptions(sessionID: UUID)
    case importProgress(sessionID: UUID)
    case duplicateReview(sessionID: UUID)
    case importSuccess(sessionID: UUID)
    case settings
    case diagnosticDetails(sessionID: UUID)
}

// MARK: - Root Navigation View

public struct RootNavigationView: View {

    @EnvironmentObject private var coordinator: AppCoordinator

    public init() {}

    public var body: some View {
        NavigationStack(path: $coordinator.path) {
            WelcomeScreen(
                hasActiveSession: coordinator.hasActiveSession,
                onGetStarted: { coordinator.navigate(to: .permissions) },
                onResumeSession: { coordinator.resumeActiveSession() }
            )
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
            }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .welcome:
            WelcomeScreen(
                hasActiveSession: coordinator.hasActiveSession,
                onGetStarted: { coordinator.navigate(to: .permissions) },
                onResumeSession: { coordinator.resumeActiveSession() }
            )

        case .permissions:
            PermissionsScreen(
                photosStatus: coordinator.photosPermissionState,
                onRequestPhotosAccess: { coordinator.requestPhotosAccess() },
                onOpenSettings: { coordinator.openSystemSettings() },
                onContinue: { coordinator.navigate(to: .importSource) }
            )

        case .importSource:
            ImportSourceScreen(
                onPickZIP: { coordinator.pickZIP() },
                onPickFolder: { coordinator.pickFolder() }
            )

        case .exportHealth(let sessionID):
            ExportHealthScreen(
                isScanning: true,
                onContinue: { coordinator.navigate(to: .importOptions(sessionID: sessionID)) },
                onCancel: { coordinator.cancelAndReturnHome() }
            )

        case .importOptions(let sessionID):
            ImportOptionsScreen(
                onStartImport: { mode, skipDupes in
                    coordinator.startImport(sessionID: sessionID, mode: mode, skipDuplicates: skipDupes)
                },
                onBack: { coordinator.goBack() }
            )

        case .importProgress(let sessionID):
            ImportProgressScreen(
                onCancel: { coordinator.cancelImport(sessionID: sessionID) }
            )

        case .duplicateReview:
            DuplicateReviewScreen(
                onDone: { coordinator.finishDuplicateReview() }
            )

        case .importSuccess:
            ImportSuccessScreen(
                onDone: { coordinator.returnHome() },
                onViewFailures: { coordinator.viewFailures() },
                onReviewDuplicates: { coordinator.openDuplicateReview() }
            )

        case .settings:
            SettingsScreen(
                onViewDiagnostics: { coordinator.viewDiagnostics() },
                onExportDiagnostics: { coordinator.exportDiagnostics() },
                onResetData: { coordinator.resetAllData() }
            )

        case .diagnosticDetails:
            // HANDOFF: Agent 6 — replace with real DiagnosticDetailsScreen
            EmptyView()
        }
    }
}
