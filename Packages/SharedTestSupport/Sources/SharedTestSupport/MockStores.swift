import Foundation
import DomainModels
import AppCore

// MARK: - MockImportSessionStore

public final class MockImportSessionStore: ImportSessionStore, @unchecked Sendable {

    private let lock = NSLock()
    private var sessions: [ImportSession] = []

    public init() {}

    public func createSession(_ draft: ImportSessionDraft) async throws -> ImportSession {
        let session = ImportSession(
            sourceType: draft.sourceType,
            sourceBookmarkData: draft.sourceBookmarkData,
            displayName: draft.displayName,
            importMode: draft.importMode
        )
        lock.lock()
        sessions.append(session)
        lock.unlock()
        return session
    }

    public func updateSession(_ session: ImportSession) async throws {
        lock.lock()
        defer { lock.unlock() }
        if let idx = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[idx] = session
        }
    }

    public func fetchSession(id: UUID) async throws -> ImportSession? {
        lock.lock()
        defer { lock.unlock() }
        return sessions.first { $0.id == id }
    }

    public func fetchActiveSession() async throws -> ImportSession? {
        lock.lock()
        defer { lock.unlock() }
        return sessions.first { $0.status == .active }
    }
}

// MARK: - MockParsedRecordStore

public final class MockParsedRecordStore: ParsedRecordStore, @unchecked Sendable {

    private let lock = NSLock()
    private var records: [ParsedSnapRecord] = []

    public init() {}

    public func save(_ records: [ParsedSnapRecord]) async throws {
        lock.lock()
        self.records.append(contentsOf: records)
        lock.unlock()
    }

    public func fetchRecords(sessionID: UUID) async throws -> [ParsedSnapRecord] {
        lock.lock()
        defer { lock.unlock() }
        return records.filter { $0.sessionId == sessionID }
    }
}

// MARK: - MockImportAssetStore

public final class MockImportAssetStore: ImportAssetStore, @unchecked Sendable {

    private let lock = NSLock()
    private var assets: [ImportAsset] = []

    public init() {}

    public func save(_ assets: [ImportAsset]) async throws {
        lock.lock()
        self.assets.append(contentsOf: assets)
        lock.unlock()
    }

    public func fetchAssets(sessionID: UUID) async throws -> [ImportAsset] {
        lock.lock()
        defer { lock.unlock() }
        return assets.filter { $0.sessionId == sessionID }
    }

    public func markImported(assetID: UUID, localIdentifier: String) async throws {
        lock.lock()
        defer { lock.unlock() }
        if let idx = assets.firstIndex(where: { $0.id == assetID }) {
            assets[idx].importStatus = .imported
            assets[idx].photosLocalIdentifier = localIdentifier
        }
    }

    public func markFailed(assetID: UUID, reason: ImportFailureReason) async throws {
        lock.lock()
        defer { lock.unlock() }
        if let idx = assets.firstIndex(where: { $0.id == assetID }) {
            assets[idx].importStatus = .failed
            assets[idx].failureReason = reason
        }
    }
}

// MARK: - MockDuplicateCandidateStore

public final class MockDuplicateCandidateStore: DuplicateCandidateStore, @unchecked Sendable {

    private let lock = NSLock()
    private var candidates: [DuplicateCandidate] = []

    public init() {}

    public func save(_ candidates: [DuplicateCandidate]) async throws {
        lock.lock()
        self.candidates.append(contentsOf: candidates)
        lock.unlock()
    }

    public func fetchPending(sessionID: UUID) async throws -> [DuplicateCandidate] {
        lock.lock()
        defer { lock.unlock() }
        return candidates.filter { $0.sessionId == sessionID && $0.reviewStatus == .pendingReview }
    }
}

// MARK: - MockImportFailureStore

public final class MockImportFailureStore: ImportFailureStore, @unchecked Sendable {

    private let lock = NSLock()
    private var failures: [ImportFailure] = []

    public init() {}

    public func save(_ failure: ImportFailure) async throws {
        lock.lock()
        failures.append(failure)
        lock.unlock()
    }

    public func fetchFailures(sessionID: UUID) async throws -> [ImportFailure] {
        lock.lock()
        defer { lock.unlock() }
        return failures.filter { $0.sessionId == sessionID }
    }
}

// MARK: - MockDiagnosticEventStore

public final class MockDiagnosticEventStore: DiagnosticEventStore, @unchecked Sendable {

    private let lock = NSLock()
    private var events: [DiagnosticEvent] = []

    public init() {}

    public func save(_ event: DiagnosticEvent) async throws {
        lock.lock()
        events.append(event)
        lock.unlock()
    }

    public func fetchEvents(sessionID: UUID) async throws -> [DiagnosticEvent] {
        lock.lock()
        defer { lock.unlock() }
        return events.filter { $0.sessionId == sessionID }
    }
}
