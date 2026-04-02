import Foundation
import AppCore
import DomainModels
import GRDB

public final class GRDBDiagnosticEventStore: DiagnosticEventStore, Sendable {
    private let db: AppDatabase

    public init(db: AppDatabase) {
        self.db = db
    }

    public func save(_ event: DiagnosticEvent) async throws {
        // HANDOFF: Agent 2 — implement real GRDB queries
        fatalError("Not yet implemented")
    }

    public func fetchEvents(sessionID: UUID) async throws -> [DiagnosticEvent] {
        // HANDOFF: Agent 2 — implement real GRDB queries
        return []
    }
}
