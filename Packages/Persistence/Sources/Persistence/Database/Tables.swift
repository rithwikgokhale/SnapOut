import Foundation
import GRDB

// MARK: - ImportSessionRecord

public struct ImportSessionRecord: Codable, FetchableRecord, PersistableRecord, Sendable {
    public static let databaseTableName = "import_sessions"

    public var id: String
    public var createdAt: Date
    public var updatedAt: Date
    public var sourceType: String
    public var sourceBookmarkData: Data?
    public var displayName: String
    public var status: String
    public var phase: String
    public var importMode: String
    public var healthSummarySnapshot: Data?
    public var startedAt: Date?
    public var completedAt: Date?
    public var cancelledAt: Date?
    public var totalDiscoveredCount: Int
    public var plannedImportCount: Int
    public var successfulImportCount: Int
    public var skippedCount: Int
    public var failureCount: Int
    public var requiresUserAction: Bool
    public var cleanupState: String

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case sourceType = "source_type"
        case sourceBookmarkData = "source_bookmark_data"
        case displayName = "display_name"
        case status
        case phase
        case importMode = "import_mode"
        case healthSummarySnapshot = "health_summary_snapshot"
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case cancelledAt = "cancelled_at"
        case totalDiscoveredCount = "total_discovered_count"
        case plannedImportCount = "planned_import_count"
        case successfulImportCount = "successful_import_count"
        case skippedCount = "skipped_count"
        case failureCount = "failure_count"
        case requiresUserAction = "requires_user_action"
        case cleanupState = "cleanup_state"
    }
}

// MARK: - ParsedSnapRecordRow

public struct ParsedSnapRecordRow: Codable, FetchableRecord, PersistableRecord, Sendable {
    public static let databaseTableName = "parsed_snap_records"

    public var id: String
    public var sessionId: String
    public var sourceRecordIdentifier: String?
    public var relativeMediaPath: String
    public var mediaType: String
    public var snapchatTimestamp: Date?
    public var embeddedTimestamp: Date?
    public var normalizedTimestamp: Date?
    public var locationLatitude: Double?
    public var locationLongitude: Double?
    public var locationSource: String?
    public var metadataConfidence: String
    public var rawChecksumHint: String?
    public var validationStatus: String

    enum CodingKeys: String, CodingKey {
        case id
        case sessionId = "session_id"
        case sourceRecordIdentifier = "source_record_identifier"
        case relativeMediaPath = "relative_media_path"
        case mediaType = "media_type"
        case snapchatTimestamp = "snapchat_timestamp"
        case embeddedTimestamp = "embedded_timestamp"
        case normalizedTimestamp = "normalized_timestamp"
        case locationLatitude = "location_latitude"
        case locationLongitude = "location_longitude"
        case locationSource = "location_source"
        case metadataConfidence = "metadata_confidence"
        case rawChecksumHint = "raw_checksum_hint"
        case validationStatus = "validation_status"
    }
}

// MARK: - ImportAssetRecord

public struct ImportAssetRecord: Codable, FetchableRecord, PersistableRecord, Sendable {
    public static let databaseTableName = "import_assets"

    public var id: String
    public var sessionId: String
    public var parsedRecordId: String
    public var resolvedSourcePath: String?
    public var workingFilePath: String?
    public var mediaType: String
    public var normalizedTimestamp: Date?
    public var locationLatitude: Double?
    public var locationLongitude: Double?
    public var confidence: String
    public var contentHash: String?
    public var byteSize: Int64?
    public var duration: Double?
    public var pixelWidth: Int?
    public var pixelHeight: Int?
    public var importStatus: String
    public var failureReason: String?
    public var photosLocalIdentifier: String?

    enum CodingKeys: String, CodingKey {
        case id
        case sessionId = "session_id"
        case parsedRecordId = "parsed_record_id"
        case resolvedSourcePath = "resolved_source_path"
        case workingFilePath = "working_file_path"
        case mediaType = "media_type"
        case normalizedTimestamp = "normalized_timestamp"
        case locationLatitude = "location_latitude"
        case locationLongitude = "location_longitude"
        case confidence
        case contentHash = "content_hash"
        case byteSize = "byte_size"
        case duration
        case pixelWidth = "pixel_width"
        case pixelHeight = "pixel_height"
        case importStatus = "import_status"
        case failureReason = "failure_reason"
        case photosLocalIdentifier = "photos_local_identifier"
    }
}

// MARK: - LibraryAssetCacheRecord

public struct LibraryAssetCacheRecord: Codable, FetchableRecord, PersistableRecord, Sendable {
    public static let databaseTableName = "library_asset_cache"

    public var id: String
    public var photosLocalIdentifier: String
    public var creationDate: Date?
    public var mediaType: String
    public var duration: Double?
    public var pixelWidth: Int?
    public var pixelHeight: Int?
    public var byteSizeHint: Int64?
    public var fingerprint: String?
    public var albumMembershipHint: String?

    enum CodingKeys: String, CodingKey {
        case id
        case photosLocalIdentifier = "photos_local_identifier"
        case creationDate = "creation_date"
        case mediaType = "media_type"
        case duration
        case pixelWidth = "pixel_width"
        case pixelHeight = "pixel_height"
        case byteSizeHint = "byte_size_hint"
        case fingerprint
        case albumMembershipHint = "album_membership_hint"
    }
}

// MARK: - DuplicateCandidateRecord

public struct DuplicateCandidateRecord: Codable, FetchableRecord, PersistableRecord, Sendable {
    public static let databaseTableName = "duplicate_candidates"

    public var id: String
    public var sessionId: String
    public var importAssetId: String
    public var libraryAssetLocalIdentifier: String
    public var confidence: String
    public var reasonCode: String
    public var score: Double
    public var reviewStatus: String
    public var userDecision: String?
    public var createdAt: Date
    public var resolvedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case sessionId = "session_id"
        case importAssetId = "import_asset_id"
        case libraryAssetLocalIdentifier = "library_asset_local_identifier"
        case confidence
        case reasonCode = "reason_code"
        case score
        case reviewStatus = "review_status"
        case userDecision = "user_decision"
        case createdAt = "created_at"
        case resolvedAt = "resolved_at"
    }
}

// MARK: - ImportFailureRecord

public struct ImportFailureRecord: Codable, FetchableRecord, PersistableRecord, Sendable {
    public static let databaseTableName = "import_failures"

    public var id: String
    public var sessionId: String
    public var importAssetId: String?
    public var phase: String
    public var reason: String
    public var detail: String?
    public var retryEligible: Bool
    public var createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case sessionId = "session_id"
        case importAssetId = "import_asset_id"
        case phase
        case reason
        case detail
        case retryEligible = "retry_eligible"
        case createdAt = "created_at"
    }
}

// MARK: - DiagnosticEventRecord

public struct DiagnosticEventRecord: Codable, FetchableRecord, PersistableRecord, Sendable {
    public static let databaseTableName = "diagnostic_events"

    public var id: String
    public var sessionId: String?
    public var timestamp: Date
    public var category: String
    public var message: String
    public var severity: String
    public var metadataJson: String?

    enum CodingKeys: String, CodingKey {
        case id
        case sessionId = "session_id"
        case timestamp
        case category
        case message
        case severity
        case metadataJson = "metadata_json"
    }
}

// MARK: - AppSettingRecord

public struct AppSettingRecord: Codable, FetchableRecord, PersistableRecord, Sendable {
    public static let databaseTableName = "app_settings"

    public var key: String
    public var valueJson: String?

    enum CodingKeys: String, CodingKey {
        case key
        case valueJson = "value_json"
    }
}
