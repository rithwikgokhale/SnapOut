import Foundation

/// Lightweight configuration for the app environment.
/// Downstream agents can extend this with runtime feature flags or environment-specific settings.
public enum AppEnvironment {
    case debug
    case release

    public static var current: AppEnvironment {
        #if DEBUG
        return .debug
        #else
        return .release
        #endif
    }

    public var isDebug: Bool { self == .debug }

    public var masterAlbumName: String { "Snapchat Memories" }

    public var databaseFileName: String { "snapout.sqlite" }
}
