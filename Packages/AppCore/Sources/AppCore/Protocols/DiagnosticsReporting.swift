import Foundation
import DomainModels

public protocol DiagnosticsReporting: Sendable {
    func log(_ event: DiagnosticEvent) async
    func summary(for sessionID: UUID) async throws -> DiagnosticSummary
}
