import Foundation
import DomainModels

public protocol PhotosLibraryQuerying: Sendable {
    func fetchCandidateAssets(
        near date: Date,
        mediaType: MediaType
    ) async throws -> [LibraryAssetReference]

    func fetchAssetDetails(
        localIdentifiers: [String]
    ) async throws -> [LibraryAssetReference]
}
