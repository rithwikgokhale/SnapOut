import Foundation
import DomainModels
import AppCore

/// Handles resume-after-interruption by checking asset statuses
/// and re-queuing any that were in-flight.
public final class ResumeEngine: Sendable {

    public init() {}

    public func assetsNeedingResume(sessionID: UUID) async throws -> [ImportAsset] {
        // HANDOFF: Agent 4 — query store for incomplete assets
        return []
    }
}
