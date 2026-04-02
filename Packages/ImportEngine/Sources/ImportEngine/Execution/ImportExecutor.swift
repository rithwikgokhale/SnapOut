import Foundation
import DomainModels
import AppCore

/// Runs the actual import loop: stage file → resolve metadata → write to Photos.
public final class ImportExecutor: Sendable {

    public init() {}

    public func execute(
        assets: [ImportAsset],
        sessionID: UUID
    ) async throws {
        // HANDOFF: Agent 4 — implement per-asset pipeline
        throw ImportEngineError.notImplemented
    }
}
