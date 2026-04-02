import Foundation
import AppCore
import DomainModels
import GRDB

public final class GRDBImportAssetStore: ImportAssetStore, Sendable {
    private let db: AppDatabase

    public init(db: AppDatabase) {
        self.db = db
    }

    public func save(_ assets: [ImportAsset]) async throws {
        // HANDOFF: Agent 2 — implement real GRDB queries
        fatalError("Not yet implemented")
    }

    public func fetchAssets(sessionID: UUID) async throws -> [ImportAsset] {
        // HANDOFF: Agent 2 — implement real GRDB queries
        return []
    }

    public func markImported(assetID: UUID, localIdentifier: String) async throws {
        // HANDOFF: Agent 2 — implement real GRDB queries
        fatalError("Not yet implemented")
    }

    public func markFailed(assetID: UUID, reason: ImportFailureReason) async throws {
        // HANDOFF: Agent 2 — implement real GRDB queries
        fatalError("Not yet implemented")
    }
}
