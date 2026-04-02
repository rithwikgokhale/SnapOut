import Foundation
import DomainModels

/// Validates the internal structure of a Snapchat export directory.
public final class ExportStructureValidator: Sendable {

    public init() {}

    /// Returns an array of human-readable validation messages.
    /// An empty array means valid.
    public func validate(entries: [ImportSourceEntry]) -> [String] {
        // HANDOFF: Agent 3 — implement structure rules
        return []
    }
}
