// HANDOFF: Agent 4 — owns planning/execution/resume phases

import Foundation
import DomainModels
import AppCore

public final class ExecutionCoordinator: Sendable {

    public init() {}

    public func buildPlan(sessionID: UUID, mode: ImportMode) async throws {
        throw ImportEngineError.notImplemented
    }

    public func runImport(sessionID: UUID) async throws {
        throw ImportEngineError.notImplemented
    }

    public func resumeImport(sessionID: UUID) async throws {
        throw ImportEngineError.notImplemented
    }

    public func cancelImport(sessionID: UUID) async throws {
        throw ImportEngineError.notImplemented
    }
}
