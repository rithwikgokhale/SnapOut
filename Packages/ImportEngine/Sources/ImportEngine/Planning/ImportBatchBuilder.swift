import Foundation
import DomainModels

/// Splits a flat asset list into sized batches for memory-bounded execution.
public final class ImportBatchBuilder: Sendable {

    public init() {}

    public func buildBatches(
        from assets: [ImportAsset],
        maxBatchSize: Int = 50
    ) -> [[ImportAsset]] {
        // HANDOFF: Agent 4 — implement chunking with size heuristics
        guard !assets.isEmpty else { return [] }
        return stride(from: 0, to: assets.count, by: maxBatchSize).map {
            Array(assets[$0..<min($0 + maxBatchSize, assets.count)])
        }
    }
}
