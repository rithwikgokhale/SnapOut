import Foundation

public struct ImportFailure: Identifiable, Codable, Sendable {
    public var id: UUID
    public var sessionId: UUID
    public var importAssetId: UUID?
    public var phase: String
    public var reason: ImportFailureReason
    public var detail: String?
    public var retryEligible: Bool
    public var createdAt: Date

    public init(
        id: UUID = UUID(),
        sessionId: UUID,
        importAssetId: UUID? = nil,
        phase: String,
        reason: ImportFailureReason,
        detail: String? = nil,
        retryEligible: Bool = false,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.sessionId = sessionId
        self.importAssetId = importAssetId
        self.phase = phase
        self.reason = reason
        self.detail = detail
        self.retryEligible = retryEligible
        self.createdAt = createdAt
    }
}
