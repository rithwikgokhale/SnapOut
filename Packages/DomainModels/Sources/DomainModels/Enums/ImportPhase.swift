import Foundation

public enum ImportPhase: String, Codable, Sendable {
    case created
    case awaitingPermission = "awaiting_permission"
    case awaitingSource = "awaiting_source"
    case scanning
    case scanned
    case planning
    case dedupeIndexing = "dedupe_indexing"
    case dedupeMatching = "dedupe_matching"
    case awaitingReview = "awaiting_review"
    case importing
    case postImportReview = "post_import_review"
    case completed
    case cleanup
    case failed
    case canceled
}
