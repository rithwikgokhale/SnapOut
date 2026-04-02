import Foundation

public struct ImportAsset: Identifiable, Codable, Sendable {
    public var id: UUID
    public var sessionId: UUID
    public var parsedRecordId: UUID
    public var resolvedSourcePath: String?
    public var workingFilePath: String?
    public var mediaType: MediaType
    public var normalizedTimestamp: Date?
    public var locationLatitude: Double?
    public var locationLongitude: Double?
    public var confidence: MetadataConfidence
    public var contentHash: String?
    public var byteSize: Int64?
    public var duration: Double?
    public var pixelWidth: Int?
    public var pixelHeight: Int?
    public var importStatus: ImportAssetStatus
    public var failureReason: ImportFailureReason?
    public var photosLocalIdentifier: String?

    public init(
        id: UUID = UUID(),
        sessionId: UUID,
        parsedRecordId: UUID,
        resolvedSourcePath: String? = nil,
        workingFilePath: String? = nil,
        mediaType: MediaType,
        normalizedTimestamp: Date? = nil,
        locationLatitude: Double? = nil,
        locationLongitude: Double? = nil,
        confidence: MetadataConfidence = .low,
        contentHash: String? = nil,
        byteSize: Int64? = nil,
        duration: Double? = nil,
        pixelWidth: Int? = nil,
        pixelHeight: Int? = nil,
        importStatus: ImportAssetStatus = .queued,
        failureReason: ImportFailureReason? = nil,
        photosLocalIdentifier: String? = nil
    ) {
        self.id = id
        self.sessionId = sessionId
        self.parsedRecordId = parsedRecordId
        self.resolvedSourcePath = resolvedSourcePath
        self.workingFilePath = workingFilePath
        self.mediaType = mediaType
        self.normalizedTimestamp = normalizedTimestamp
        self.locationLatitude = locationLatitude
        self.locationLongitude = locationLongitude
        self.confidence = confidence
        self.contentHash = contentHash
        self.byteSize = byteSize
        self.duration = duration
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.importStatus = importStatus
        self.failureReason = failureReason
        self.photosLocalIdentifier = photosLocalIdentifier
    }
}
