import Foundation
import DomainModels

public protocol DuplicateReviewActing: Sendable {
    func recordDecision(
        candidateID: UUID,
        decision: DuplicateReviewDecision
    ) async throws

    func deleteReviewedLibraryAssets(
        candidateIDs: [UUID]
    ) async throws
}
