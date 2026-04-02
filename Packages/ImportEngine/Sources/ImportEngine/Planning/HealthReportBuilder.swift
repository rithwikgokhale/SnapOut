import Foundation
import DomainModels
import AppCore

/// Builds an `ExportHealthReport` summarizing data quality for the user.
public final class HealthReportBuilder: ExportHealthReporting, Sendable {

    public init() {}

    public func buildHealthReport(
        sessionID: UUID,
        parsedRecords: [ParsedSnapRecord]
    ) async throws -> ExportHealthReport {
        // HANDOFF: Agent 3 — implement health scoring algorithm
        return ExportHealthReport(sessionId: sessionID)
    }
}
