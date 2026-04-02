import Foundation
import DomainModels
import AppCore

/// Resolves the best available metadata for a parsed record by layering
/// Snapchat export JSON, embedded EXIF, and file-timestamp sources.
public final class MetadataResolver: MetadataResolving, Sendable {

    public init() {}

    public func resolveMetadata(
        for record: ParsedSnapRecord,
        mediaFileURL: URL?
    ) async throws -> ResolvedMetadata {
        // HANDOFF: Agent 3 — implement multi-source metadata resolution
        throw ImportEngineError.notImplemented
    }
}
