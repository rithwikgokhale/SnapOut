import Foundation
import GRDB

public struct AppMigrations {
    public static func register(in migrator: inout DatabaseMigrator) {
        migrator.registerMigration("v1") { db in
            // import_sessions
            try db.create(table: "import_sessions") { t in
                t.column("id", .text).primaryKey()
                t.column("created_at", .datetime).notNull()
                t.column("updated_at", .datetime).notNull()
                t.column("source_type", .text).notNull()
                t.column("source_bookmark_data", .blob)
                t.column("display_name", .text).notNull()
                t.column("status", .text).notNull()
                t.column("phase", .text).notNull()
                t.column("import_mode", .text).notNull()
                t.column("health_summary_snapshot", .blob)
                t.column("started_at", .datetime)
                t.column("completed_at", .datetime)
                t.column("cancelled_at", .datetime)
                t.column("total_discovered_count", .integer).notNull().defaults(to: 0)
                t.column("planned_import_count", .integer).notNull().defaults(to: 0)
                t.column("successful_import_count", .integer).notNull().defaults(to: 0)
                t.column("skipped_count", .integer).notNull().defaults(to: 0)
                t.column("failure_count", .integer).notNull().defaults(to: 0)
                t.column("requires_user_action", .integer).notNull().defaults(to: 0)
                t.column("cleanup_state", .text).notNull()
            }

            // parsed_snap_records
            try db.create(table: "parsed_snap_records") { t in
                t.column("id", .text).primaryKey()
                t.column("session_id", .text).notNull().references("import_sessions", onDelete: .cascade)
                t.column("source_record_identifier", .text)
                t.column("relative_media_path", .text).notNull()
                t.column("media_type", .text).notNull()
                t.column("snapchat_timestamp", .datetime)
                t.column("embedded_timestamp", .datetime)
                t.column("normalized_timestamp", .datetime)
                t.column("location_latitude", .double)
                t.column("location_longitude", .double)
                t.column("location_source", .text)
                t.column("metadata_confidence", .text).notNull()
                t.column("raw_checksum_hint", .text)
                t.column("validation_status", .text).notNull()
            }

            // import_assets
            try db.create(table: "import_assets") { t in
                t.column("id", .text).primaryKey()
                t.column("session_id", .text).notNull().references("import_sessions", onDelete: .cascade)
                t.column("parsed_record_id", .text).notNull()
                t.column("resolved_source_path", .text)
                t.column("working_file_path", .text)
                t.column("media_type", .text).notNull()
                t.column("normalized_timestamp", .datetime)
                t.column("location_latitude", .double)
                t.column("location_longitude", .double)
                t.column("confidence", .text).notNull()
                t.column("content_hash", .text)
                t.column("byte_size", .integer)
                t.column("duration", .double)
                t.column("pixel_width", .integer)
                t.column("pixel_height", .integer)
                t.column("import_status", .text).notNull()
                t.column("failure_reason", .text)
                t.column("photos_local_identifier", .text)
            }

            // library_asset_cache
            try db.create(table: "library_asset_cache") { t in
                t.column("id", .text).primaryKey()
                t.column("photos_local_identifier", .text).notNull()
                t.column("creation_date", .datetime)
                t.column("media_type", .text).notNull()
                t.column("duration", .double)
                t.column("pixel_width", .integer)
                t.column("pixel_height", .integer)
                t.column("byte_size_hint", .integer)
                t.column("fingerprint", .text)
                t.column("album_membership_hint", .text)
            }

            // duplicate_candidates
            try db.create(table: "duplicate_candidates") { t in
                t.column("id", .text).primaryKey()
                t.column("session_id", .text).notNull().references("import_sessions", onDelete: .cascade)
                t.column("import_asset_id", .text).notNull()
                t.column("library_asset_local_identifier", .text).notNull()
                t.column("confidence", .text).notNull()
                t.column("reason_code", .text).notNull()
                t.column("score", .double).notNull()
                t.column("review_status", .text).notNull()
                t.column("user_decision", .text)
                t.column("created_at", .datetime).notNull()
                t.column("resolved_at", .datetime)
            }

            // import_failures
            try db.create(table: "import_failures") { t in
                t.column("id", .text).primaryKey()
                t.column("session_id", .text).notNull().references("import_sessions", onDelete: .cascade)
                t.column("import_asset_id", .text)
                t.column("phase", .text).notNull()
                t.column("reason", .text).notNull()
                t.column("detail", .text)
                t.column("retry_eligible", .integer).notNull().defaults(to: 0)
                t.column("created_at", .datetime).notNull()
            }

            // diagnostic_events
            try db.create(table: "diagnostic_events") { t in
                t.column("id", .text).primaryKey()
                t.column("session_id", .text)
                t.column("timestamp", .datetime).notNull()
                t.column("category", .text).notNull()
                t.column("message", .text).notNull()
                t.column("severity", .text).notNull()
                t.column("metadata_json", .text)
            }

            // app_settings
            try db.create(table: "app_settings") { t in
                t.column("key", .text).primaryKey()
                t.column("value_json", .text)
            }

            // Indexes
            try db.create(index: "idx_parsed_snap_records_session_id", on: "parsed_snap_records", columns: ["session_id"])
            try db.create(index: "idx_import_assets_session_id", on: "import_assets", columns: ["session_id"])
            try db.create(index: "idx_import_assets_import_status", on: "import_assets", columns: ["import_status"])
            try db.create(index: "idx_import_assets_normalized_timestamp", on: "import_assets", columns: ["normalized_timestamp"])
            try db.create(index: "idx_duplicate_candidates_session_id", on: "duplicate_candidates", columns: ["session_id"])
            try db.create(index: "idx_duplicate_candidates_review_status", on: "duplicate_candidates", columns: ["review_status"])
            try db.create(index: "idx_import_failures_session_id", on: "import_failures", columns: ["session_id"])
            try db.create(index: "idx_library_asset_cache_photos_id", on: "library_asset_cache", columns: ["photos_local_identifier"])
        }
    }
}
