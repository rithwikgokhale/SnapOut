import Foundation
import DomainModels

// MARK: - ImportSessionStore

public protocol ImportSessionStore: Sendable {
    func createSession(_ draft: ImportSessionDraft) async throws -> ImportSession
    func updateSession(_ session: ImportSession) async throws
    func fetchSession(id: UUID) async throws -> ImportSession?
    func fetchActiveSession() async throws -> ImportSession?
}

// MARK: - ParsedRecordStore

public protocol ParsedRecordStore: Sendable {
    func save(_ records: [ParsedSnapRecord]) async throws
    func fetchRecords(sessionID: UUID) async throws -> [ParsedSnapRecord]
}

// MARK: - ImportAssetStore

public protocol ImportAssetStore: Sendable {
    func save(_ assets: [ImportAsset]) async throws
    func fetchAssets(sessionID: UUID) async throws -> [ImportAsset]
    func markImported(assetID: UUID, localIdentifier: String) async throws
    func markFailed(assetID: UUID, reason: ImportFailureReason) async throws
}

// MARK: - DuplicateCandidateStore

public protocol DuplicateCandidateStore: Sendable {
    func save(_ candidates: [DuplicateCandidate]) async throws
    func fetchPending(sessionID: UUID) async throws -> [DuplicateCandidate]
}

// MARK: - ImportFailureStore

public protocol ImportFailureStore: Sendable {
    func save(_ failure: ImportFailure) async throws
    func fetchFailures(sessionID: UUID) async throws -> [ImportFailure]
}

// MARK: - DiagnosticEventStore

public protocol DiagnosticEventStore: Sendable {
    func save(_ event: DiagnosticEvent) async throws
    func fetchEvents(sessionID: UUID) async throws -> [DiagnosticEvent]
}
