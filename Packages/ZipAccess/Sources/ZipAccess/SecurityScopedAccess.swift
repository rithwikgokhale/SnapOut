import Foundation

/// Thin wrapper around iOS security-scoped resource access APIs.
public struct SecurityScopedAccess: Sendable {

    private init() {}

    @discardableResult
    public static func startAccessing(url: URL) -> Bool {
        url.startAccessingSecurityScopedResource()
    }

    public static func stopAccessing(url: URL) {
        url.stopAccessingSecurityScopedResource()
    }

    public static func createBookmarkData(for url: URL) throws -> Data {
        try url.bookmarkData(options: .minimalBookmark, includingResourceValuesForKeys: nil, relativeTo: nil)
    }

    public static func resolveBookmarkData(_ data: Data) throws -> URL {
        var isStale = false
        let url = try URL(resolvingBookmarkData: data, options: [], relativeTo: nil, bookmarkDataIsStale: &isStale)
        return url
    }
}
