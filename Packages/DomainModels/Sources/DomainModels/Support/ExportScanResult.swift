import Foundation

public struct ExportScanResult: Codable, Sendable {
    public var isValid: Bool
    public var manifestFound: Bool
    public var totalEntries: Int
    public var mediaEntries: Int
    public var estimatedSizeBytes: UInt64
    public var validationMessages: [String]

    public init(
        isValid: Bool = false,
        manifestFound: Bool = false,
        totalEntries: Int = 0,
        mediaEntries: Int = 0,
        estimatedSizeBytes: UInt64 = 0,
        validationMessages: [String] = []
    ) {
        self.isValid = isValid
        self.manifestFound = manifestFound
        self.totalEntries = totalEntries
        self.mediaEntries = mediaEntries
        self.estimatedSizeBytes = estimatedSizeBytes
        self.validationMessages = validationMessages
    }
}
