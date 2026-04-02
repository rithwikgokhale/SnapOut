import Foundation
import AppCore
import DomainModels
import GRDB

public final class GRDBDuplicateCandidateStore: DuplicateCandidateStore, Sendable {
    private let db: AppDatabase

    public init(db: AppDatabase) {
        self.db = db
    }

    public func save(_ candidates: [DuplicateCandidate]) async throws {
        // HANDOFF: Agent 2 — implement real GRDB queries
        fatalError("Not yet implemented")
    }

    public func fetchPending(sessionID: UUID) async throws -> [DuplicateCandidate] {
        // HANDOFF: Agent 2 — implement real GRDB queries
        return []
    }
}
