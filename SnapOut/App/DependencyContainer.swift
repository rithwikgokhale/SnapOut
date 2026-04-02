import Foundation
import AppCore
import DomainModels
import Persistence
import ImportEngine
import PhotosAccess
import DedupeEngine
import Diagnostics
import ZipAccess

/// Composition root: wires concrete implementations to AppCore protocols.
/// Organized by domain so downstream agents can fill in real implementations
/// without stepping on each other.
@MainActor
public final class DependencyContainer: ObservableObject {

    // MARK: - Environment

    public let environment = AppEnvironment.current

    // MARK: - Database (Agent 2: Persistence)

    public let database: AppDatabase

    // MARK: - Stores (Agent 2: Persistence)

    public let importSessionStore: any ImportSessionStore
    public let parsedRecordStore: any ParsedRecordStore
    public let importAssetStore: any ImportAssetStore
    public let duplicateCandidateStore: any DuplicateCandidateStore
    public let importFailureStore: any ImportFailureStore
    public let diagnosticEventStore: any DiagnosticEventStore

    // MARK: - Photos (Agent 4: Photos/Import)

    public let photosAuthorizer: any PhotosLibraryAuthorizing
    public let photosWriter: any PhotosAssetWriting
    public let photosQuerier: any PhotosLibraryQuerying

    // MARK: - Import Engine (Agent 3: Parser + Agent 4: Import)

    public let importCoordinator: any ImportCoordinating

    // MARK: - Dedupe (Agent 5: Dedupe)

    public let duplicateAnalyzer: any DuplicateAnalyzing

    // MARK: - Diagnostics (Agent 6: Diagnostics)

    public let diagnosticsReporter: any DiagnosticsReporting

    // MARK: - Initialization

    public init() {
        // Database
        self.database = AppDatabase.shared

        // Stores — stub implementations, Agent 2 replaces with real GRDB queries
        self.importSessionStore = GRDBImportSessionStore(db: database)
        self.parsedRecordStore = GRDBParsedRecordStore(db: database)
        self.importAssetStore = GRDBImportAssetStore(db: database)
        self.duplicateCandidateStore = GRDBDuplicateCandidateStore(db: database)
        self.importFailureStore = GRDBImportFailureStore(db: database)
        self.diagnosticEventStore = GRDBDiagnosticEventStore(db: database)

        // Photos — stub implementations, Agent 4 fills in real PhotoKit work
        self.photosAuthorizer = PhotoLibraryAuthorizer()
        self.photosWriter = PhotoAssetWriter()
        self.photosQuerier = PhotoLibraryQueryService()

        // Import Engine — stub coordinator with split sub-coordinators
        let scanCoordinator = ScanCoordinator()
        let executionCoordinator = ExecutionCoordinator()
        self.importCoordinator = ImportCoordinator(
            scanCoordinator: scanCoordinator,
            executionCoordinator: executionCoordinator
        )

        // Dedupe — stub implementation, Agent 5 fills in real analysis
        self.duplicateAnalyzer = DuplicateClassifier()

        // Diagnostics — stub reporter, Agent 6 fills in real logging pipeline
        // HANDOFF: Agent 6 — bridge DiagnosticsLogger to AppCore.DiagnosticsReporting
        self.diagnosticsReporter = StubDiagnosticsReporter()
    }
}

// MARK: - Stub Diagnostics Reporter

/// Minimal stub conforming to DiagnosticsReporting.
/// Agent 6 replaces this with the real DiagnosticsLogger bridge.
private struct StubDiagnosticsReporter: DiagnosticsReporting {
    func log(_ event: DiagnosticEvent) async {}
    func summary(for sessionID: UUID) async throws -> DiagnosticSummary {
        DiagnosticSummary(
            sessionId: sessionID,
            totalEvents: 0,
            errorCount: 0,
            warningCount: 0,
            infoCount: 0,
            topCategories: []
        )
    }
}
