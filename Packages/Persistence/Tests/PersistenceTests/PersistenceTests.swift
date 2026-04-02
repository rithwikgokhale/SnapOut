import XCTest
import GRDB
@testable import Persistence

final class PersistenceTests: XCTestCase {

    func testMakeDefaultCreatesAllTables() throws {
        let db = try AppDatabase.makeDefault()

        let tableNames: Set<String> = try db.writer.read { db in
            let rows = try Row.fetchAll(db, sql: """
                SELECT name FROM sqlite_master
                WHERE type = 'table' AND name NOT LIKE 'sqlite_%' AND name != 'grdb_migrations'
                ORDER BY name
                """)
            return Set(rows.map { $0["name"] as String })
        }

        let expected: Set<String> = [
            "import_sessions",
            "parsed_snap_records",
            "import_assets",
            "library_asset_cache",
            "duplicate_candidates",
            "import_failures",
            "diagnostic_events",
            "app_settings",
        ]

        XCTAssertEqual(tableNames, expected, "All 8 tables should be created by v1 migration")
    }

    func testMakeDefaultCreatesIndexes() throws {
        let db = try AppDatabase.makeDefault()

        let indexNames: Set<String> = try db.writer.read { db in
            let rows = try Row.fetchAll(db, sql: """
                SELECT name FROM sqlite_master WHERE type = 'index' AND name LIKE 'idx_%'
                """)
            return Set(rows.map { $0["name"] as String })
        }

        XCTAssertTrue(indexNames.contains("idx_parsed_snap_records_session_id"))
        XCTAssertTrue(indexNames.contains("idx_import_assets_session_id"))
        XCTAssertTrue(indexNames.contains("idx_import_assets_import_status"))
        XCTAssertTrue(indexNames.contains("idx_import_assets_normalized_timestamp"))
        XCTAssertTrue(indexNames.contains("idx_duplicate_candidates_session_id"))
        XCTAssertTrue(indexNames.contains("idx_duplicate_candidates_review_status"))
        XCTAssertTrue(indexNames.contains("idx_import_failures_session_id"))
        XCTAssertTrue(indexNames.contains("idx_library_asset_cache_photos_id"))
    }
}
