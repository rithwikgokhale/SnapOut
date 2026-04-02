import Foundation

public enum PermissionsState: String, Codable, Sendable {
    case notDetermined
    case authorized
    case limited
    case denied
    case restricted
}
