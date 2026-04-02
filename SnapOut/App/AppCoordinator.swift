import SwiftUI
import DomainModels

/// Observable app coordinator managing navigation state and delegating user actions.
/// Real business logic for each action will be filled in by downstream agents.
@MainActor
public final class AppCoordinator: ObservableObject {

    // MARK: - Navigation State

    @Published public var path = NavigationPath()

    // MARK: - App State (stubs — downstream agents fill these)

    @Published public var hasActiveSession: Bool = false
    @Published public var photosPermissionState: PermissionsState = .notDetermined
    @Published public var activeSessionID: UUID?

    // MARK: - Dependency Container

    private let container: DependencyContainer

    public init(container: DependencyContainer) {
        self.container = container
    }

    // MARK: - Navigation

    public func navigate(to route: AppRoute) {
        path.append(route)
    }

    public func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    public func returnHome() {
        path = NavigationPath()
    }

    // MARK: - Session Actions (stubs)

    public func resumeActiveSession() {
        // HANDOFF: Agent 4 — load active session, determine correct resume point
        guard let sessionID = activeSessionID else { return }
        navigate(to: .importProgress(sessionID: sessionID))
    }

    // MARK: - Permissions Actions (stubs)

    public func requestPhotosAccess() {
        // HANDOFF: Agent 4 — call container.photosAuthorizer.requestFullAccess()
        // then update photosPermissionState
    }

    public func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }

    // MARK: - Source Selection (stubs)

    public func pickZIP() {
        // HANDOFF: Agent 3 — present document picker for .zip UTType,
        // obtain security-scoped URL, call importCoordinator.startScan
    }

    public func pickFolder() {
        // HANDOFF: Agent 3 — present folder picker,
        // obtain security-scoped URL, call importCoordinator.startScan
    }

    // MARK: - Import Actions (stubs)

    public func startImport(sessionID: UUID, mode: ImportMode, skipDuplicates: Bool) {
        // HANDOFF: Agent 4 — call buildPlan then runImport
        navigate(to: .importProgress(sessionID: sessionID))
    }

    public func cancelImport(sessionID: UUID) {
        // HANDOFF: Agent 4 — call importCoordinator.cancelImport
        returnHome()
    }

    public func cancelAndReturnHome() {
        returnHome()
    }

    // MARK: - Duplicate Review (stubs)

    public func finishDuplicateReview() {
        // HANDOFF: Agent 5 — finalize review decisions
        goBack()
    }

    public func openDuplicateReview() {
        // HANDOFF: Agent 5 — navigate to duplicate review with current session
    }

    // MARK: - Completion (stubs)

    public func viewFailures() {
        // HANDOFF: Agent 6 — navigate to failure details screen
    }

    // MARK: - Settings Actions (stubs)

    public func viewDiagnostics() {
        // HANDOFF: Agent 6 — navigate to diagnostics screen
    }

    public func exportDiagnostics() {
        // HANDOFF: Agent 6 — trigger diagnostic bundle export
    }

    public func resetAllData() {
        // HANDOFF: Agent 6 — confirm and reset database + local state
    }
}
