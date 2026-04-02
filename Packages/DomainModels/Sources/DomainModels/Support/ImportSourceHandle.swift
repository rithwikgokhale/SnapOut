import Foundation

public struct ImportSourceHandle: Sendable {
    public var sourceURL: URL
    public var sourceType: SourceType
    public var displayName: String

    public init(sourceURL: URL, sourceType: SourceType, displayName: String) {
        self.sourceURL = sourceURL
        self.sourceType = sourceType
        self.displayName = displayName
    }
}
