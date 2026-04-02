import Foundation

public struct DiagnosticEvent: Identifiable, Codable, Sendable {
    public var id: UUID
    public var sessionId: UUID?
    public var timestamp: Date
    public var category: String
    public var message: String
    public var severity: DiagnosticSeverity
    public var metadata: [String: String]?

    public init(
        id: UUID = UUID(),
        sessionId: UUID? = nil,
        timestamp: Date = Date(),
        category: String,
        message: String,
        severity: DiagnosticSeverity = .info,
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.sessionId = sessionId
        self.timestamp = timestamp
        self.category = category
        self.message = message
        self.severity = severity
        self.metadata = metadata
    }
}

public enum DiagnosticSeverity: String, Codable, Sendable {
    case info
    case warning
    case error
}
