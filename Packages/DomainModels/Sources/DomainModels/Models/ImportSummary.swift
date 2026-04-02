import Foundation

public struct ImportSummary: Codable, Sendable {
    public var sessionId: UUID
    public var importedCount: Int
    public var skippedExactDuplicates: Int
    public var suspectedDuplicatesQueued: Int
    public var failedCount: Int
    public var metadataFallbackCount: Int
    public var totalDuration: TimeInterval
    public var albumName: String

    public init(
        sessionId: UUID,
        importedCount: Int = 0,
        skippedExactDuplicates: Int = 0,
        suspectedDuplicatesQueued: Int = 0,
        failedCount: Int = 0,
        metadataFallbackCount: Int = 0,
        totalDuration: TimeInterval = 0,
        albumName: String = "Snapchat Memories"
    ) {
        self.sessionId = sessionId
        self.importedCount = importedCount
        self.skippedExactDuplicates = skippedExactDuplicates
        self.suspectedDuplicatesQueued = suspectedDuplicatesQueued
        self.failedCount = failedCount
        self.metadataFallbackCount = metadataFallbackCount
        self.totalDuration = totalDuration
        self.albumName = albumName
    }
}
