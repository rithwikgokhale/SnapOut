import Foundation

public struct ParsedSnapRecord: Identifiable, Codable, Sendable {
    public var id: UUID
    public var sessionId: UUID
    public var sourceRecordIdentifier: String?
    public var relativeMediaPath: String
    public var mediaType: MediaType
    public var snapchatTimestamp: Date?
    public var embeddedTimestamp: Date?
    public var normalizedTimestamp: Date?
    public var locationLatitude: Double?
    public var locationLongitude: Double?
    public var locationSource: String?
    public var metadataConfidence: MetadataConfidence
    public var rawChecksumHint: String?
    public var validationStatus: ValidationStatus

    public init(
        id: UUID = UUID(),
        sessionId: UUID,
        sourceRecordIdentifier: String? = nil,
        relativeMediaPath: String,
        mediaType: MediaType,
        snapchatTimestamp: Date? = nil,
        embeddedTimestamp: Date? = nil,
        normalizedTimestamp: Date? = nil,
        locationLatitude: Double? = nil,
        locationLongitude: Double? = nil,
        locationSource: String? = nil,
        metadataConfidence: MetadataConfidence = .low,
        rawChecksumHint: String? = nil,
        validationStatus: ValidationStatus = .valid
    ) {
        self.id = id
        self.sessionId = sessionId
        self.sourceRecordIdentifier = sourceRecordIdentifier
        self.relativeMediaPath = relativeMediaPath
        self.mediaType = mediaType
        self.snapchatTimestamp = snapchatTimestamp
        self.embeddedTimestamp = embeddedTimestamp
        self.normalizedTimestamp = normalizedTimestamp
        self.locationLatitude = locationLatitude
        self.locationLongitude = locationLongitude
        self.locationSource = locationSource
        self.metadataConfidence = metadataConfidence
        self.rawChecksumHint = rawChecksumHint
        self.validationStatus = validationStatus
    }
}
