import Testing
@testable import AppCore

@Test func appCoreProtocolsExist() {
    // Compile-time validation that protocol types exist
    let _: any ImportSourceAccessing.Type = (any ImportSourceAccessing).self
    let _: any ImportCoordinating.Type = (any ImportCoordinating).self
    let _: any ImportSessionStore.Type = (any ImportSessionStore).self
}
