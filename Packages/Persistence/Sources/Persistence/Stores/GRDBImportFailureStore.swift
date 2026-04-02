import Foundation
import AppCore
import DomainModels
import GRDB

public final class GRDBImportFailureStore: ImportFailureStore, Sendable {
    private let db: AppDatabase

    public init(db: AppDatabase) {
        self.db = db
    }

    public func save(_ failure: ImportFailure) async throws {
        // HANDOFF: Agent 2 — implement real GRDB queries
        fatalError("Not yet implemented")
    }

    public func fetchFailures(sessionID: UUID) async throws -> [ImportFailure] {
        // HANDOFF: Agent 2 — implement real GRDB queries
        return []
    }
}
