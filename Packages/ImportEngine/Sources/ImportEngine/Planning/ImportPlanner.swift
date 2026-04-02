import Foundation
import DomainModels
import AppCore

/// Transforms parsed records + health data into a set of `ImportAsset` entries
/// ready for execution.
public final class ImportPlanner: Sendable {

    public init() {}

    public func buildPlan(
        sessionID: UUID,
        records: [ParsedSnapRecord],
        mode: ImportMode
    ) async throws -> [ImportAsset] {
        // HANDOFF: Agent 4 — implement asset plan creation
        return []
    }
}
