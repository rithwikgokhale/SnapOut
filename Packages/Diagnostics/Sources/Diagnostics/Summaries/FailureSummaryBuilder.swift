import Foundation
import DomainModels

/// Produces a human-readable summary of failures from diagnostic events.
public final class FailureSummaryBuilder: Sendable {

    public init() {}

    /// Returns a multi-line string describing all error-level events.
    public func buildFailureSummary(events: [DiagnosticEvent]) -> String {
        let errorEvents = events.filter { $0.severity == .error }
        guard !errorEvents.isEmpty else { return "No failures recorded." }

        return errorEvents.map { "[\($0.category)] \($0.message)" }.joined(separator: "\n")
    }
}
