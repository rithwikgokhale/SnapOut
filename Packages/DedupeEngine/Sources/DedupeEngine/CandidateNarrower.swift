import Foundation
import DomainModels
import AppCore

/// Narrows the Photos library search space to a small set of candidate assets
/// that might be duplicates of a given import asset.
public final class CandidateNarrower: Sendable {

    public init() {}

    /// Returns library assets that fall within a narrow time/type window around the import asset.
    public func narrowCandidates(
        for asset: ImportAsset,
        from libraryAssets: [LibraryAssetReference]
    ) -> [LibraryAssetReference] {
        // HANDOFF: Agent 5 — implement date-window + media-type filtering
        return []
    }
}
