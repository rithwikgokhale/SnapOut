// HANDOFF: Agent 3 — add AppCore dependency and conform to ImportSourceAccessing

import Foundation

/// Provides read access to an unzipped Snapchat export folder.
/// Method signatures mirror `ImportSourceAccessing` from AppCore; protocol
/// conformance is wired up once ZipAccess gains an AppCore dependency.
public final class FolderImportSourceAccessor: Sendable {

    public init() {}

    public func openSource(url: URL) async throws -> ZIPSourceHandle {
        throw ZipAccessError.notImplemented
    }

    public func closeSource(_ handle: ZIPSourceHandle) async {
        // no-op stub
    }

    public func listEntries(in handle: ZIPSourceHandle) async throws -> [ZIPSourceEntry] {
        throw ZipAccessError.notImplemented
    }

    public func extractEntry(
        _ entry: ZIPSourceEntry,
        from handle: ZIPSourceHandle,
        to destinationURL: URL
    ) async throws -> URL {
        throw ZipAccessError.notImplemented
    }

    public func fileExists(
        at relativePath: String,
        in handle: ZIPSourceHandle
    ) async throws -> Bool {
        throw ZipAccessError.notImplemented
    }
}
