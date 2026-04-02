import Foundation

public struct ImportSessionDraft: Sendable {
    public var sourceType: SourceType
    public var sourceBookmarkData: Data?
    public var displayName: String
    public var importMode: ImportMode

    public init(
        sourceType: SourceType,
        sourceBookmarkData: Data? = nil,
        displayName: String,
        importMode: ImportMode = .bestEffort
    ) {
        self.sourceType = sourceType
        self.sourceBookmarkData = sourceBookmarkData
        self.displayName = displayName
        self.importMode = importMode
    }
}
