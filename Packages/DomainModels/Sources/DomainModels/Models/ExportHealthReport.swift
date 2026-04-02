import Foundation

public struct ExportHealthReport: Codable, Sendable {
    public var sessionId: UUID
    public var totalDiscovered: Int
    public var matchedMedia: Int
    public var missingReferences: Int
    public var timestampCoverage: Double
    public var locationCoverage: Double
    public var unsupportedItems: Int
    public var healthScore: Int
    public var warnings: [String]

    public init(
        sessionId: UUID,
        totalDiscovered: Int = 0,
        matchedMedia: Int = 0,
        missingReferences: Int = 0,
        timestampCoverage: Double = 0,
        locationCoverage: Double = 0,
        unsupportedItems: Int = 0,
        healthScore: Int = 0,
        warnings: [String] = []
    ) {
        self.sessionId = sessionId
        self.totalDiscovered = totalDiscovered
        self.matchedMedia = matchedMedia
        self.missingReferences = missingReferences
        self.timestampCoverage = timestampCoverage
        self.locationCoverage = locationCoverage
        self.unsupportedItems = unsupportedItems
        self.healthScore = healthScore
        self.warnings = warnings
    }

    public var healthLabel: String {
        switch healthScore {
        case 90...100: return "Excellent"
        case 75..<90: return "Good"
        case 50..<75: return "Mixed"
        default: return "Fragile"
        }
    }
}
