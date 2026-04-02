import Foundation
import DomainModels
import AppCore

/// Parses a Snapchat export source into an array of `ParsedSnapRecord`.
public final class SnapchatExportParser: SnapchatExportParsing, Sendable {

    public init() {}

    public func scanSource(_ source: ImportSourceHandle) async throws -> ExportScanResult {
        // HANDOFF: Agent 3 — delegates to SnapchatExportScanner
        throw ImportEngineError.notImplemented
    }

    public func parseExport(_ source: ImportSourceHandle) async throws -> [ParsedSnapRecord] {
        // HANDOFF: Agent 3 — implement JSON manifest + file system walk
        throw ImportEngineError.notImplemented
    }
}
