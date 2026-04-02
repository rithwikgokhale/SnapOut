import Foundation

public enum CleanupState: String, Codable, Sendable {
    case pending
    case inProgress = "in_progress"
    case completed
    case failed
}
