import Foundation

public struct ResolvedMetadata: Codable, Sendable {
    public var creationDate: Date?
    public var latitude: Double?
    public var longitude: Double?
    public var confidence: MetadataConfidence
    public var source: MetadataSource
    public var fallbackReason: String?

    public init(
        creationDate: Date? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        confidence: MetadataConfidence = .low,
        source: MetadataSource = .fallback,
        fallbackReason: String? = nil
    ) {
        self.creationDate = creationDate
        self.latitude = latitude
        self.longitude = longitude
        self.confidence = confidence
        self.source = source
        self.fallbackReason = fallbackReason
    }
}

public enum MetadataSource: String, Codable, Sendable {
    case export
    case embedded
    case fileTimestamp = "file_timestamp"
    case fallback
}
