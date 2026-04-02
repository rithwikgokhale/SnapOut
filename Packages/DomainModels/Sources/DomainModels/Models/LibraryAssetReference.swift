import Foundation

public struct LibraryAssetReference: Identifiable, Codable, Sendable {
    public var id: UUID
    public var photosLocalIdentifier: String
    public var creationDate: Date?
    public var mediaType: MediaType
    public var duration: Double?
    public var pixelWidth: Int?
    public var pixelHeight: Int?
    public var byteSizeHint: Int64?
    public var fingerprint: String?
    public var albumMembershipHint: String?

    public init(
        id: UUID = UUID(),
        photosLocalIdentifier: String,
        creationDate: Date? = nil,
        mediaType: MediaType,
        duration: Double? = nil,
        pixelWidth: Int? = nil,
        pixelHeight: Int? = nil,
        byteSizeHint: Int64? = nil,
        fingerprint: String? = nil,
        albumMembershipHint: String? = nil
    ) {
        self.id = id
        self.photosLocalIdentifier = photosLocalIdentifier
        self.creationDate = creationDate
        self.mediaType = mediaType
        self.duration = duration
        self.pixelWidth = pixelWidth
        self.pixelHeight = pixelHeight
        self.byteSizeHint = byteSizeHint
        self.fingerprint = fingerprint
        self.albumMembershipHint = albumMembershipHint
    }
}
