import Foundation

public enum PhotosAuthorizationState: Sendable {
    case notDetermined
    case fullAccess
    case limitedAccess
    case denied
    case restricted
}
