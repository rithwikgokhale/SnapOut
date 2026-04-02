import Foundation
import AppCore
import DomainModels
import GRDB

public final class GRDBParsedRecordStore: ParsedRecordStore, Sendable {
    private let db: AppDatabase

    public init(db: AppDatabase) {
        self.db = db
    }

    public func save(_ records: [ParsedSnapRecord]) async throws {
        // HANDOFF: Agent 2 — implement real GRDB queries
        fatalError("Not yet implemented")
    }

    public func fetchRecords(sessionID: UUID) async throws -> [ParsedSnapRecord] {
        // HANDOFF: Agent 2 — implement real GRDB queries
        return []
    }
}
