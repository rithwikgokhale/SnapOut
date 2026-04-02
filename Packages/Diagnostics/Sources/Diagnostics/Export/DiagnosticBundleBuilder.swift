import Foundation
import DomainModels

/// Assembles diagnostic events, summaries, and logs into a shareable bundle (e.g. JSON file).
public final class DiagnosticBundleBuilder: Sendable {

    public init() {}

    /// Builds a JSON-encoded diagnostic bundle and writes it to a temporary file.
    /// Returns the URL of the created bundle.
    public func buildBundle(
        sessionID: UUID,
        events: [DiagnosticEvent],
        summary: DiagnosticSummary
    ) throws -> URL {
        // HANDOFF: Agent 6 — implement JSON export + optional zip
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        let payload = DiagnosticBundle(sessionID: sessionID, events: events, summary: summary)
        let data = try encoder.encode(payload)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("SnapOut-Diagnostics-\(sessionID.uuidString).json")
        try data.write(to: url)
        return url
    }
}

private struct DiagnosticBundle: Codable {
    let sessionID: UUID
    let events: [DiagnosticEvent]
    let summary: DiagnosticSummary
}
