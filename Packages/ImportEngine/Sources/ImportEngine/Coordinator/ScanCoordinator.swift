// HANDOFF: Agent 3 — owns scan/parse/health phases

import Foundation
import DomainModels
import AppCore

public final class ScanCoordinator: Sendable {

    public init() {}

    /// Scans the source at `sourceURL`, validates its structure, parses records,
    /// and returns a new `ImportSession` in the `.scanned` phase.
    public func startScan(sourceURL: URL) async throws -> ImportSession {
        throw ImportEngineError.notImplemented
    }
}
