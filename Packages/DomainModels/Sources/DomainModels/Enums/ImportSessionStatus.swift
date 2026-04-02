import Foundation

public enum ImportSessionStatus: String, Codable, Sendable {
    case active
    case paused
    case completed
    case failed
    case canceled
}
