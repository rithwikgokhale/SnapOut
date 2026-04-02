import Foundation

public struct DuplicateCandidate: Identifiable, Codable, Sendable {
    public var id: UUID
    public var sessionId: UUID
    public var importAssetId: UUID
    public var libraryAssetLocalIdentifier: String
    public var confidence: DuplicateConfidence
    public var reasonCode: DuplicateReasonCode
    public var score: Double
    public var reviewStatus: ReviewStatus
    public var userDecision: DuplicateReviewDecision?
    public var createdAt: Date
    public var resolvedAt: Date?

    public init(
        id: UUID = UUID(),
        sessionId: UUID,
        importAssetId: UUID,
        libraryAssetLocalIdentifier: String,
        confidence: DuplicateConfidence,
        reasonCode: DuplicateReasonCode,
        score: Double,
        reviewStatus: ReviewStatus = .pendingReview,
        userDecision: DuplicateReviewDecision? = nil,
        createdAt: Date = Date(),
        resolvedAt: Date? = nil
    ) {
        self.id = id
        self.sessionId = sessionId
        self.importAssetId = importAssetId
        self.libraryAssetLocalIdentifier = libraryAssetLocalIdentifier
        self.confidence = confidence
        self.reasonCode = reasonCode
        self.score = score
        self.reviewStatus = reviewStatus
        self.userDecision = userDecision
        self.createdAt = createdAt
        self.resolvedAt = resolvedAt
    }
}
