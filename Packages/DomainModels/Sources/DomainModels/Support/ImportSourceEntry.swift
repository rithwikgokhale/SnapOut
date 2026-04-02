import Foundation

public struct ImportSourceEntry: Sendable {
    public var relativePath: String
    public var isDirectory: Bool
    public var compressedSize: UInt64?
    public var uncompressedSize: UInt64?

    public init(
        relativePath: String,
        isDirectory: Bool = false,
        compressedSize: UInt64? = nil,
        uncompressedSize: UInt64? = nil
    ) {
        self.relativePath = relativePath
        self.isDirectory = isDirectory
        self.compressedSize = compressedSize
        self.uncompressedSize = uncompressedSize
    }
}
