import Foundation

public enum ValidationStatus: String, Codable, Sendable {
    case valid
    case missingMedia = "missing_media"
    case unsupported
    case corrupt
}
