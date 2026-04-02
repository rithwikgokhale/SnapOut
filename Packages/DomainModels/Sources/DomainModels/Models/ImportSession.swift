import Foundation

public struct ImportSession: Identifiable, Codable, Sendable {
    public var id: UUID
    public var createdAt: Date
    public var updatedAt: Date
    public var sourceType: SourceType
    public var sourceBookmarkData: Data?
    public var displayName: String
    public var status: ImportSessionStatus
    public var phase: ImportPhase
    public var importMode: ImportMode
    public var healthSummarySnapshot: Data?
    public var startedAt: Date?
    public var completedAt: Date?
    public var cancelledAt: Date?
    public var totalDiscoveredCount: Int
    public var plannedImportCount: Int
    public var successfulImportCount: Int
    public var skippedCount: Int
    public var failureCount: Int
    public var requiresUserAction: Bool
    public var cleanupState: CleanupState

    public init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        sourceType: SourceType,
        sourceBookmarkData: Data? = nil,
        displayName: String,
        status: ImportSessionStatus = .active,
        phase: ImportPhase = .created,
        importMode: ImportMode = .bestEffort,
        healthSummarySnapshot: Data? = nil,
        startedAt: Date? = nil,
        completedAt: Date? = nil,
        cancelledAt: Date? = nil,
        totalDiscoveredCount: Int = 0,
        plannedImportCount: Int = 0,
        successfulImportCount: Int = 0,
        skippedCount: Int = 0,
        failureCount: Int = 0,
        requiresUserAction: Bool = false,
        cleanupState: CleanupState = .pending
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.sourceType = sourceType
        self.sourceBookmarkData = sourceBookmarkData
        self.displayName = displayName
        self.status = status
        self.phase = phase
        self.importMode = importMode
        self.healthSummarySnapshot = healthSummarySnapshot
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.cancelledAt = cancelledAt
        self.totalDiscoveredCount = totalDiscoveredCount
        self.plannedImportCount = plannedImportCount
        self.successfulImportCount = successfulImportCount
        self.skippedCount = skippedCount
        self.failureCount = failureCount
        self.requiresUserAction = requiresUserAction
        self.cleanupState = cleanupState
    }
}
