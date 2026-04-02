import Foundation

/// Manages the temporary working directory used for staging extracted files
/// before they are written into the Photos library.
public final class WorkingDirectoryManager: Sendable {

    public init() {}

    public func createWorkingDirectory(for sessionID: UUID) throws -> URL {
        let base = FileManager.default.temporaryDirectory
            .appendingPathComponent("SnapOut", isDirectory: true)
            .appendingPathComponent(sessionID.uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base
    }

    public func cleanupWorkingDirectory(for sessionID: UUID) throws {
        let base = FileManager.default.temporaryDirectory
            .appendingPathComponent("SnapOut", isDirectory: true)
            .appendingPathComponent(sessionID.uuidString, isDirectory: true)
        if FileManager.default.fileExists(atPath: base.path) {
            try FileManager.default.removeItem(at: base)
        }
    }
}
