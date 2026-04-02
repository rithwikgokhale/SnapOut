import Foundation
import DomainModels

/// Standalone diagnostics logger that records events in-memory and to a backing store.
/// Does NOT conform to `AppCore.DiagnosticsReporting` because the Diagnostics
/// package does not depend on AppCore. Conformance is bridged at the app composition root.
public final class DiagnosticsLogger: @unchecked Sendable {

    private let lock = NSLock()
    private var events: [DiagnosticEvent] = []

    public init() {}

    public func log(_ event: DiagnosticEvent) {
        lock.lock()
        events.append(event)
        lock.unlock()
    }

    public func log(
        category: String,
        message: String,
        severity: DiagnosticSeverity = .info,
        sessionId: UUID? = nil,
        metadata: [String: String]? = nil
    ) {
        let event = DiagnosticEvent(
            sessionId: sessionId,
            category: category,
            message: message,
            severity: severity,
            metadata: metadata
        )
        log(event)
    }

    public func fetchEvents(sessionID: UUID) -> [DiagnosticEvent] {
        lock.lock()
        defer { lock.unlock() }
        return events.filter { $0.sessionId == sessionID }
    }

    public func allEvents() -> [DiagnosticEvent] {
        lock.lock()
        defer { lock.unlock() }
        return events
    }
}
