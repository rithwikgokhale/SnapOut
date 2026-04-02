import Foundation
import Photos
import DomainModels
import AppCore

public final class PhotoAssetWriter: PhotosAssetWriting, Sendable {

    public init() {}

    public func saveAsset(
        from fileURL: URL,
        metadata: ResolvedMetadata,
        into album: PhotosAlbumReference
    ) async throws -> String {
        // HANDOFF: Agent 4 — implement PHAssetCreationRequest with metadata injection
        throw PhotosAccessError.notImplemented
    }
}
