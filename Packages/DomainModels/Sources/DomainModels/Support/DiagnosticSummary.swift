import Foundation

public struct DiagnosticSummary: Codable, Sendable {
    public var sessionId: UUID
    public var totalEvents: Int
    public var errorCount: Int
    public var warningCount: Int
    public var phaseDurations: [String: TimeInterval]

    public init(
        sessionId: UUID,
        totalEvents: Int = 0,
        errorCount: Int = 0,
        warningCount: Int = 0,
        phaseDurations: [String: TimeInterval] = [:]
    ) {
        self.sessionId = sessionId
        self.totalEvents = totalEvents
        self.errorCount = errorCount
        self.warningCount = warningCount
        self.phaseDurations = phaseDurations
    }
}
