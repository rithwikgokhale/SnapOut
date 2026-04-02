// HANDOFF: Agent 3 — add AppCore dependency and conform to ImportSourceAccessing

import Foundation
import ZIPFoundation

public enum ZipAccessError: Error, Sendable {
    case notImplemented
}

/// Provides read access to Snapchat export ZIP archives.
/// Method signatures mirror `ImportSourceAccessing` from AppCore; protocol
/// conformance is wired up once ZipAccess gains an AppCore dependency.
public final class ZIPImportSourceAccessor: Sendable {

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

// MARK: - Local value types (mirror DomainModels shapes without the dependency)

public struct ZIPSourceHandle: Sendable {
    public var sourceURL: URL
    public var displayName: String

    public init(sourceURL: URL, displayName: String) {
        self.sourceURL = sourceURL
        self.displayName = displayName
    }
}

public struct ZIPSourceEntry: Sendable {
    public var relativePath: String
    public var isDirectory: Bool
    public var compressedSize: UInt64?
    public var uncompressedSize: UInt64?

    public init(
        relativePath: String,
        isDirectory: Bool = false,
        compressedSize: UInt64? = nil,
        uncompressedSize: UInt64? = nil
    ) {
        self.relativePath = relativePath
        self.isDirectory = isDirectory
        self.compressedSize = compressedSize
        self.uncompressedSize = uncompressedSize
    }
}
