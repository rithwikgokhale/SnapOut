import Foundation
import DomainModels

public protocol MetadataResolving: Sendable {
    func resolveMetadata(
        for record: ParsedSnapRecord,
        mediaFileURL: URL?
    ) async throws -> ResolvedMetadata
}
