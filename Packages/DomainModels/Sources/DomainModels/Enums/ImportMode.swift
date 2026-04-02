import Foundation

public enum ImportMode: String, Codable, Sendable {
    case bestEffort = "best_effort"
    case strict = "strict"
}
