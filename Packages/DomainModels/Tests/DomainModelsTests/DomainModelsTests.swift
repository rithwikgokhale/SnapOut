import Testing
@testable import DomainModels

@Test func importSessionDefaults() {
    let session = ImportSession(sourceType: .zip, displayName: "Test Export")
    #expect(session.status == .active)
    #expect(session.phase == .created)
    #expect(session.importMode == .bestEffort)
    #expect(session.totalDiscoveredCount == 0)
}
