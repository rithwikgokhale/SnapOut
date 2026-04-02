import Foundation
import DomainModels
import AppCore

/// Performs fast structural scan of the source archive/folder to detect
/// whether it looks like a valid Snapchat export.
public final class SnapchatExportScanner: Sendable {

    public init() {}

    public func scan(source: ImportSourceHandle) async throws -> ExportScanResult {
        // HANDOFF: Agent 3 — implement directory walk + manifest detection
        throw ImportEngineError.notImplemented
    }
}
