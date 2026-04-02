
# SnapOut — Shell Foundation Freeze

**Date:** 2026-03-30
**Status:** Frozen (pending full iOS build verification — Xcode.app not installed)

This document records the shared-foundation artifacts produced during the Shell Milestone. These are **frozen** — downstream agents should not modify them without explicit approval.

---

## 1. Frozen AppCore Protocols

All protocols are in `Packages/AppCore/Sources/AppCore/Protocols/`. AppCore depends only on `DomainModels`.

| Protocol | File | Purpose |
|----------|------|---------|
| `ImportSourceAccessing` | ImportSourceAccessing.swift | Access source files from ZIP or folder |
| `SnapchatExportParsing` | SnapchatExportParsing.swift | Parse Snapchat export manifests |
| `ExportHealthReporting` | ExportHealthReporting.swift | Generate export health reports |
| `MetadataResolving` | MetadataResolving.swift | Resolve and merge metadata from multiple sources |
| `PhotosLibraryAuthorizing` | PhotosLibraryAuthorizing.swift | Request and check Photos library authorization |
| `PhotosLibraryQuerying` | PhotosLibraryQuerying.swift | Query existing Photos library assets |
| `PhotosAssetWriting` | PhotosAssetWriting.swift | Write/create assets in Photos library |
| `DuplicateAnalyzing` | DuplicateAnalyzing.swift | Analyze imports for duplicates against library |
| `DuplicateReviewActing` | DuplicateReviewActing.swift | Execute user decisions on duplicate candidates |
| `ImportCoordinating` | ImportCoordinating.swift | Top-level import orchestration (delegates to Scan/Execution) |
| `DiagnosticsReporting` | DiagnosticsReporting.swift | Log and retrieve diagnostic events |
| `ImportSessionStore` | Stores.swift | CRUD for import sessions |
| `ParsedRecordStore` | Stores.swift | CRUD for parsed snap records |
| `ImportAssetStore` | Stores.swift | CRUD for import assets |
| `DuplicateCandidateStore` | Stores.swift | CRUD for duplicate candidates |
| `ImportFailureStore` | Stores.swift | CRUD for import failures |
| `DiagnosticEventStore` | Stores.swift | CRUD for diagnostic events |

**Freeze status:** Ready to freeze. Protocols are thin, contain no concrete logic, and depend only on DomainModels types.

---

## 2. Frozen DomainModels Types and Enums

All files in `Packages/DomainModels/Sources/DomainModels/`. No external dependencies.

### Enums (15)

| Enum | File |
|------|------|
| `ImportMode` | Enums/ImportMode.swift |
| `ImportPhase` | Enums/ImportPhase.swift |
| `ImportSessionStatus` | Enums/ImportSessionStatus.swift |
| `MetadataConfidence` | Enums/MetadataConfidence.swift |
| `DuplicateConfidence` | Enums/DuplicateConfidence.swift |
| `DuplicateReasonCode` | Enums/DuplicateReasonCode.swift |
| `DuplicateReviewDecision` | Enums/DuplicateReviewDecision.swift |
| `ImportFailureReason` | Enums/ImportFailureReason.swift |
| `CleanupState` | Enums/CleanupState.swift |
| `PermissionsState` | Enums/PermissionsState.swift |
| `MediaType` | Enums/MediaType.swift |
| `SourceType` | Enums/SourceType.swift |
| `ValidationStatus` | Enums/ValidationStatus.swift |
| `ReviewStatus` | Enums/ReviewStatus.swift |
| `ImportAssetStatus` | Enums/ImportAssetStatus.swift |

### Models (8)

| Model | File |
|-------|------|
| `ImportSession` | Models/ImportSession.swift |
| `ParsedSnapRecord` | Models/ParsedSnapRecord.swift |
| `ImportAsset` | Models/ImportAsset.swift |
| `DuplicateCandidate` | Models/DuplicateCandidate.swift |
| `LibraryAssetReference` | Models/LibraryAssetReference.swift |
| `ExportHealthReport` | Models/ExportHealthReport.swift |
| `ImportSummary` | Models/ImportSummary.swift |
| `ImportFailure` | Models/ImportFailure.swift |

### Support Types (9)

| Type | File |
|------|------|
| `PhotosAlbumReference` | Support/PhotosAlbumReference.swift |
| `ResolvedMetadata` + `MetadataSource` enum | Support/ResolvedMetadata.swift |
| `DiagnosticEvent` + `DiagnosticSeverity` enum | Support/DiagnosticEvent.swift |
| `DiagnosticSummary` | Support/DiagnosticSummary.swift |
| `ImportSourceHandle` | Support/ImportSourceHandle.swift |
| `ImportSourceEntry` | Support/ImportSourceEntry.swift |
| `ExportScanResult` | Support/ExportScanResult.swift |
| `ImportSessionDraft` | Support/ImportSessionDraft.swift |
| `PhotosAuthorizationState` | Support/PhotosAuthorizationState.swift |

**Freeze status:** Ready to freeze. All types are value types (structs/enums), Sendable, and Codable where appropriate.

---

## 3. Frozen Database Schema

File: `Packages/Persistence/Sources/Persistence/Database/Migrations.swift`

### Tables (8)

| Table | Primary Key | Foreign Keys | Notable Columns |
|-------|-------------|-------------|-----------------|
| `import_sessions` | `id` (text) | — | source_bookmark_data (blob), all phase/status as text |
| `parsed_snap_records` | `id` (text) | session_id → import_sessions (cascade) | metadata_confidence, validation_status as text |
| `import_assets` | `id` (text) | session_id → import_sessions (cascade) | content_hash, photos_local_identifier |
| `library_asset_cache` | `id` (text) | — | photos_local_identifier, fingerprint |
| `duplicate_candidates` | `id` (text) | session_id → import_sessions (cascade) | confidence, reason_code, score, review_status |
| `import_failures` | `id` (text) | session_id → import_sessions (cascade) | phase, reason, retry_eligible |
| `diagnostic_events` | `id` (text) | — | session_id (nullable), category, severity |
| `app_settings` | `key` (text) | — | value_json (text) |

### Indexes (8)

- `idx_parsed_snap_records_session_id`
- `idx_import_assets_session_id`
- `idx_import_assets_import_status`
- `idx_import_assets_normalized_timestamp`
- `idx_duplicate_candidates_session_id`
- `idx_duplicate_candidates_review_status`
- `idx_import_failures_session_id`
- `idx_library_asset_cache_photos_id`

**Freeze status:** Ready to freeze. Schema uses text-based enum storage with nullable columns where appropriate. Foreign keys with cascade delete on session_id. All columns align with DomainModels field names (snake_case).

---

## 4. Frozen RootNavigation Routes

File: `SnapOut/App/RootNavigation.swift`

```swift
public enum AppRoute: Hashable {
    case welcome
    case permissions
    case importSource
    case exportHealth(sessionID: UUID)
    case importOptions(sessionID: UUID)
    case importProgress(sessionID: UUID)
    case duplicateReview(sessionID: UUID)
    case importSuccess(sessionID: UUID)
    case settings
    case diagnosticDetails(sessionID: UUID)
}
```

| Route | Destination Screen | Package |
|-------|-------------------|---------|
| `.welcome` | WelcomeScreen | FeatureWelcome |
| `.permissions` | PermissionsScreen | FeaturePermissions |
| `.importSource` | ImportSourceScreen | FeatureImportSource |
| `.exportHealth(sessionID:)` | ExportHealthScreen | FeatureExportHealth |
| `.importOptions(sessionID:)` | ImportOptionsScreen | FeatureImportOptions |
| `.importProgress(sessionID:)` | ImportProgressScreen | FeatureImportProgress |
| `.duplicateReview(sessionID:)` | DuplicateReviewScreen | FeatureDuplicateReview |
| `.importSuccess(sessionID:)` | ImportSuccessScreen | FeatureImportSuccess |
| `.settings` | SettingsScreen | FeatureSettings |
| `.diagnosticDetails(sessionID:)` | EmptyView (placeholder) | Agent 6 |

**Freeze status:** Frozen. Routes match the screen inventory from the repo brief. Navigation uses `NavigationStack` with `NavigationPath`. Welcome screen is the root (not in the path).

---

## 5. Frozen DesignSystem Tokens and Components

All files in `Packages/DesignSystem/Sources/DesignSystem/`.

### Tokens (4)

| Token | File | Purpose |
|-------|------|---------|
| `AppColor` | Tokens/AppColor.swift | Semantic colors (primary, background, text, accent, etc.) |
| `AppText` | Tokens/AppText.swift | Typography styles (largeTitle through caption) |
| `AppSpacing` | Tokens/AppSpacing.swift | Spacing scale (xs through xxxl) |
| `AppRadius` | Tokens/AppRadius.swift | Corner radius scale (small, medium, large, xl) |

### Components (18)

**Buttons (3):** PrimaryButton, SecondaryButton, DestructiveButton
**Cards (5):** SectionCard, StatCard, HealthSummaryCard, ProgressCard, IssueCard
**Rows (2):** InfoRow, SettingsRow
**Badges (2):** StatusBadge, MetadataConfidenceBadge
**States (4):** EmptyStateView, ErrorStateView, LoadingStateView, PermissionExplainerView
**Layout (2):** ScreenHeader, BottomActionBar

**Freeze status:** Ready to freeze. All components use semantic tokens. No hardcoded colors or sizes. Native iOS aesthetic with SF Pro + SF Symbols.

---

## 6. Proposed Changes Intentionally Deferred

| Change | Reason |
|--------|--------|
| Real parser logic | Blocked on sample Snapchat export data |
| PhotoKit write/delete logic | Agent 4 scope |
| Dedupe analysis pipeline | Agent 5 scope |
| Session resume / recovery flow | Agent 4 scope (depends on ImportCoordinator state machine) |
| Background processing / BGTaskScheduler | Not in shell scope; v1+ consideration |
| Diagnostic export to shareable file | Agent 6 scope |
| Real store implementations (GRDB queries) | Agent 2 scope |
| App Settings screen with actual preferences | Agent 6 scope |

---

## 7. Items Requiring Review Before Final Freeze

1. **RecordMappers.swift** in Persistence contains fully implemented bidirectional mappers. Agent 2 should decide whether to keep, refine, or replace.
2. **DiagnosticsLogger.swift** contains a functional in-memory logger. Agent 6 should evaluate if this aligns with their approach.
3. **DuplicateReasonBuilder.swift** contains a functional switch statement for reason descriptions. Agent 5 should evaluate.
4. **Persistence/Package.swift** has a `.macOS(.v14)` platform that was not in the original brief. Should be reviewed and possibly removed.
5. **SharedTestSupport/Package.swift** was updated to depend on AppCore (necessary for mock store conformance). This is reasonable but should be noted.
