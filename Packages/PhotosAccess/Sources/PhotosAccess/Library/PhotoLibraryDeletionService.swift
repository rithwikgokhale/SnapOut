import Foundation
import Photos
import DomainModels

/// Handles deletion of Photos library assets as part of post-review cleanup.
public final class PhotoLibraryDeletionService: Sendable {

    public init() {}

    /// Deletes assets from the user's library after duplicate-review approval.
    public func deleteAssets(localIdentifiers: [String]) async throws {
        // HANDOFF: Agent 5 — implement PHAssetChangeRequest.deleteAssets
        fatalError("PhotoLibraryDeletionService.deleteAssets not yet implemented")
    }
}
