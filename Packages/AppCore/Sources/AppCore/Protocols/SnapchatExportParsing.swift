import Foundation
import DomainModels

public protocol SnapchatExportParsing: Sendable {
    func scanSource(_ source: ImportSourceHandle) async throws -> ExportScanResult
    func parseExport(_ source: ImportSourceHandle) async throws -> [ParsedSnapRecord]
}
