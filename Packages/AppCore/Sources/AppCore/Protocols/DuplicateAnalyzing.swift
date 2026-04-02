import Foundation
import DomainModels

public protocol DuplicateAnalyzing: Sendable {
    func buildCandidates(
        for asset: ImportAsset
    ) async throws -> [DuplicateCandidate]

    func classifyDuplicate(
        importAsset: ImportAsset,
        libraryAsset: LibraryAssetReference
    ) async throws -> DuplicateCandidate
}
