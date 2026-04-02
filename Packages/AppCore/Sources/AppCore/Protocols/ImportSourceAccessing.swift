import Foundation
import DomainModels

public protocol ImportSourceAccessing: Sendable {
    func openSource(url: URL) async throws -> ImportSourceHandle
    func closeSource(_ handle: ImportSourceHandle) async
    func listEntries(in handle: ImportSourceHandle) async throws -> [ImportSourceEntry]
    func extractEntry(
        _ entry: ImportSourceEntry,
        from handle: ImportSourceHandle,
        to destinationURL: URL
    ) async throws -> URL
    func fileExists(
        at relativePath: String,
        in handle: ImportSourceHandle
    ) async throws -> Bool
}
