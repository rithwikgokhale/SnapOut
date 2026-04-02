import Foundation

public enum ImportAssetStatus: String, Codable, Sendable {
    case queued
    case staging
    case importing
    case imported
    case skippedDuplicate = "skipped_duplicate"
    case heldForReview = "held_for_review"
    case failed
}
