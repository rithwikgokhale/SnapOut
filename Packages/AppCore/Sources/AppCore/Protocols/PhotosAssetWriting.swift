import Foundation
import DomainModels

public protocol PhotosAssetWriting: Sendable {
    func saveAsset(
        from fileURL: URL,
        metadata: ResolvedMetadata,
        into album: PhotosAlbumReference
    ) async throws -> String
}
