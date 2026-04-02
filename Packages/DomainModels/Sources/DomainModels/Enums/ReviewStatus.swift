import Foundation

public enum ReviewStatus: String, Codable, Sendable {
    case pendingReview = "pending_review"
    case reviewed
    case skipped
}
