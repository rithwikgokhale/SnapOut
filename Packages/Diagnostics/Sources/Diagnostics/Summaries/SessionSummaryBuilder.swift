import Foundation
import DomainModels

/// Builds a `DiagnosticSummary` for a completed import session.
public final class SessionSummaryBuilder: Sendable {

    public init() {}

    public func buildSummary(
        sessionID: UUID,
        events: [DiagnosticEvent]
    ) -> DiagnosticSummary {
        let errors = events.filter { $0.severity == .error }.count
        let warnings = events.filter { $0.severity == .warning }.count
        return DiagnosticSummary(
            sessionId: sessionID,
            totalEvents: events.count,
            errorCount: errors,
            warningCount: warnings
        )
    }
}
