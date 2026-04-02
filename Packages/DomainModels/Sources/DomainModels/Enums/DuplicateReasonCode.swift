import Foundation

public enum DuplicateReasonCode: String, Codable, Sendable {
    case exactHash = "exact_hash"
    case strongMetadata = "strong_metadata"
    case perceptualMatch = "perceptual_match"
    case dimensionAndDateMatch = "dimension_and_date_match"
    case durationAndDateMatch = "duration_and_date_match"
}
