import Foundation

public enum ImportEngineError: Error, Sendable {
    case notImplemented
    case sessionNotFound(UUID)
    case scanFailed(String)
    case parseFailed(String)
    case executionFailed(String)
}
