import Foundation
import DomainModels

/// Emits real-time import progress via an `AsyncStream`.
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public final class ImportProgressEmitter: Sendable {

    public struct Progress: Sendable {
        public var sessionID: UUID
        public var completed: Int
        public var total: Int
        public var currentAssetName: String?

        public init(sessionID: UUID, completed: Int, total: Int, currentAssetName: String? = nil) {
            self.sessionID = sessionID
            self.completed = completed
            self.total = total
            self.currentAssetName = currentAssetName
        }
    }

    private let streamContinuation: AsyncStream<Progress>.Continuation
    public let progressStream: AsyncStream<Progress>

    public init() {
        var continuation: AsyncStream<Progress>.Continuation!
        self.progressStream = AsyncStream { continuation = $0 }
        self.streamContinuation = continuation
    }

    public func emit(_ progress: Progress) {
        streamContinuation.yield(progress)
    }

    public func finish() {
        streamContinuation.finish()
    }
}
