import Foundation
import DomainModels
import AppCore

/// Top-level coordinator that delegates scan and execution work
/// to `ScanCoordinator` and `ExecutionCoordinator` respectively.
public final class ImportCoordinator: ImportCoordinating, Sendable {

    private let scanCoordinator: ScanCoordinator
    private let executionCoordinator: ExecutionCoordinator

    public init(
        scanCoordinator: ScanCoordinator,
        executionCoordinator: ExecutionCoordinator
    ) {
        self.scanCoordinator = scanCoordinator
        self.executionCoordinator = executionCoordinator
    }

    public func startScan(sourceURL: URL) async throws -> ImportSession {
        try await scanCoordinator.startScan(sourceURL: sourceURL)
    }

    public func buildPlan(sessionID: UUID, mode: ImportMode) async throws {
        try await executionCoordinator.buildPlan(sessionID: sessionID, mode: mode)
    }

    public func runImport(sessionID: UUID) async throws {
        try await executionCoordinator.runImport(sessionID: sessionID)
    }

    public func resumeImport(sessionID: UUID) async throws {
        try await executionCoordinator.resumeImport(sessionID: sessionID)
    }

    public func cancelImport(sessionID: UUID) async throws {
        try await executionCoordinator.cancelImport(sessionID: sessionID)
    }
}
