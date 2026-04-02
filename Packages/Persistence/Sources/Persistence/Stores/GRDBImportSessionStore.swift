import Foundation
import AppCore
import DomainModels
import GRDB

public final class GRDBImportSessionStore: ImportSessionStore, Sendable {
    private let db: AppDatabase

    public init(db: AppDatabase) {
        self.db = db
    }

    public func createSession(_ draft: ImportSessionDraft) async throws -> ImportSession {
        // HANDOFF: Agent 2 — implement real GRDB queries
        fatalError("Not yet implemented")
    }

    public func updateSession(_ session: ImportSession) async throws {
        // HANDOFF: Agent 2 — implement real GRDB queries
        fatalError("Not yet implemented")
    }

    public func fetchSession(id: UUID) async throws -> ImportSession? {
        // HANDOFF: Agent 2 — implement real GRDB queries
        return nil
    }

    public func fetchActiveSession() async throws -> ImportSession? {
        // HANDOFF: Agent 2 — implement real GRDB queries
        return nil
    }
}
