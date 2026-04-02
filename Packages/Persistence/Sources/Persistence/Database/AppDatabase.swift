import Foundation
import GRDB
import DomainModels

public final class AppDatabase: Sendable {
    public let writer: any DatabaseWriter

    public init(_ writer: any DatabaseWriter) {
        self.writer = writer
    }

    // TODO: Replace with file-backed DatabasePool for production
    public static let shared: AppDatabase = {
        do {
            return try makeDefault()
        } catch {
            fatalError("AppDatabase.shared failed to initialize: \(error)")
        }
    }()

    public static func makeDefault() throws -> AppDatabase {
        let dbQueue = try DatabaseQueue(configuration: Self.makeConfiguration())
        let db = AppDatabase(dbQueue)
        try db.runMigrations()
        return db
    }

    private static func makeConfiguration() -> Configuration {
        var config = Configuration()
        #if DEBUG
        config.prepareDatabase { db in
            db.trace { print("SQL: \($0)") }
        }
        #endif
        return config
    }

    private func runMigrations() throws {
        var migrator = DatabaseMigrator()
        #if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
        #endif
        AppMigrations.register(in: &migrator)
        try migrator.migrate(writer)
    }
}
