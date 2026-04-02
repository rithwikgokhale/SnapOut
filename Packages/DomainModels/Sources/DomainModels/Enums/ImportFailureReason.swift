import Foundation

public enum ImportFailureReason: String, Codable, Sendable {
    case mediaUnreadable = "media_unreadable"
    case unsupportedFormat = "unsupported_format"
    case photoKitWriteFailed = "photokit_write_failed"
    case albumAssignmentFailed = "album_assignment_failed"
    case storageFull = "storage_full"
    case permissionRevoked = "permission_revoked"
    case stagingFailed = "staging_failed"
    case metadataInsufficient = "metadata_insufficient"
    case unknown
}
