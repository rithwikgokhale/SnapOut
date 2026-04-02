import Foundation

public struct PhotosAlbumReference: Codable, Sendable {
    public var localIdentifier: String
    public var title: String

    public init(localIdentifier: String, title: String) {
        self.localIdentifier = localIdentifier
        self.title = title
    }
}
