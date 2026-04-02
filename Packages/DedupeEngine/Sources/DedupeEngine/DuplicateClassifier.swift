import Foundation
import DomainModels
import AppCore

/// Classifies potential duplicates and computes confidence scores.
public final class DuplicateClassifier: DuplicateAnalyzing, Sendable {

    public init() {}

    public func buildCandidates(
        for asset: ImportAsset
    ) async throws -> [DuplicateCandidate] {
        // HANDOFF: Agent 5 — implement narrowing + scoring pipeline
        return []
    }

    public func classifyDuplicate(
        importAsset: ImportAsset,
        libraryAsset: LibraryAssetReference
    ) async throws -> DuplicateCandidate {
        // HANDOFF: Agent 5 — implement multi-signal classification
        throw DedupeEngineError.notImplemented
    }
}
