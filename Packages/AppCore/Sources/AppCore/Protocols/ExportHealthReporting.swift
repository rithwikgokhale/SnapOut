import Foundation
import DomainModels

public protocol ExportHealthReporting: Sendable {
    func buildHealthReport(
        sessionID: UUID,
        parsedRecords: [ParsedSnapRecord]
    ) async throws -> ExportHealthReport
}
