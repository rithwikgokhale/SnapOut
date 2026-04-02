import Foundation
import DomainModels

public protocol ImportCoordinating: Sendable {
    func startScan(sourceURL: URL) async throws -> ImportSession
    func buildPlan(sessionID: UUID, mode: ImportMode) async throws
    func runImport(sessionID: UUID) async throws
    func resumeImport(sessionID: UUID) async throws
    func cancelImport(sessionID: UUID) async throws
}
