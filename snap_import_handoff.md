
% Snapchat Memories Import Utility — Technical Architecture & Cursor Handoff
% Prepared for product/engineering handoff
% March 30, 2026

# 1. Document purpose

This document is the build-ready handoff package for the Snapchat Memories Import Utility v1. It is written to bridge product, engineering, and implementation. The immediate audience is:

- founder / product lead
- engineering lead
- Cursor as the code-generation and implementation environment

This document assumes the strategic decisions are already locked and focuses on what to build, how it should work, and how the system should be structured so implementation can begin without re-litigating core scope.

# 2. Locked decisions

## 2.1 Product and platform decisions already locked

| Area | Locked decision |
|---|---|
| Primary platform | iPhone-first |
| Future extensibility | Shared core should be reusable by a future Mac target |
| Photos access | Full Photos read/write access is required |
| Access fallback | Limited Photos access is not sufficient for v1; block and require full access |
| Import source | Official Snapchat export only |
| Accepted input forms | Official export ZIP and extracted official export folder |
| ZIP strategy | Process from the picked source; do not first copy the full ZIP into app sandbox |
| Processing model | On-device only |
| Backend | No media backend, no cloud storage, no account system |
| Default import mode | Best effort |
| Optional import mode | Strict mode |
| Dedupe scope | Full on-device library dedupe |
| Duplicate deletion | Review-only in v1; no auto-delete |
| Import execution | Foreground-primary |
| Recovery model | Resumable and idempotent |
| Album strategy | One master album in v1 |
| Scale target | Engineer for large imports, with 20 GB as the design target |

## 2.2 Product promise

The app is a private import-and-restoration utility for Snapchat Memories. It does not try to be a social app, a slideshow app, or a cloud backup system in v1.

The promise is:

> Import official Snapchat Memories into Apple Photos accurately, privately, and safely, while restoring order, dates, and usability.

## 2.3 Non-goals for v1

These are explicitly out of scope for v1:

- Android support
- iPad-first custom UX
- Mac app shipping in v1
- live Snapchat sync
- Snapchat login integration
- slideshow generation
- face recognition
- auto-delete duplicates
- cloud backup / sync
- sharing features
- user accounts
- subscription packaging decisions

# 3. System goals and design principles

## 3.1 Primary engineering goals

1. Correctness of import results
2. Trustworthy privacy posture
3. Stability on large imports
4. Deterministic resumability
5. Safe duplicate handling
6. Clear explanation of what happened during import
7. Architecture that can be handed to Cursor without ambiguity

## 3.2 Design principles

### Private by construction

All media processing should remain on-device. Any diagnostics should be local and user-exported manually if ever needed.

### Streaming over copying

The importer should avoid duplicating the entire source ZIP into app storage. Work from a security-scoped source URL and extract only what is needed into a managed working directory.

### Manifest-first pipeline

The app should treat the Snapchat export as a manifest-driven import job, not as an unstructured folder of files. Parse metadata first, then build the import plan, then execute.

### State machine, not one-shot workflow

Import should be modeled as a resumable state machine with explicit checkpoints and durable local persistence.

### Dedupe should be layered

Do not hash the whole photo library up front unless absolutely necessary. Use a tiered approach: library indexing, candidate narrowing, then expensive verification.

### UI should reveal confidence and risk

The app should explain input health, metadata health, duplicate confidence, import outcomes, and unresolved failures in plain language.

# 4. Architecture overview

## 4.1 Recommended top-level architecture

The app should be organized as a thin UI layer over a shared application core. All import logic, parsing, dedupe logic, and persistence should live in reusable core modules so the same logic can later be used by a Mac target.

Recommended architecture style:

- presentation layer: SwiftUI
- app coordination layer: flow coordinator + screen view models
- domain layer: use cases / services / actors
- infrastructure layer: PhotoKit, ZIP reader, file access, SQLite/GRDB, logging, hashing, AVFoundation, ImageIO

## 4.2 High-level architecture diagram

```text
┌────────────────────────────────────────────────────────────────────┐
│                           iOS App Shell                           │
│  SwiftUI screens, navigation, permission gating, progress UI      │
└────────────────────────────────────────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────────────────────┐
│                        Application Layer                           │
│  ImportCoordinator • SessionCoordinator • ReviewCoordinator        │
│  Use cases: ScanExport, BuildPlan, RunImport, ReviewDuplicates     │
└────────────────────────────────────────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────────────────────┐
│                           Domain Core                              │
│  ExportParser • MetadataResolver • HealthScorer                   │
│  LibraryIndexer • DuplicateEngine • ImportPlanner                 │
│  PhotosWriter • ResumeEngine • CleanupManager                     │
└────────────────────────────────────────────────────────────────────┘
                 │
                 ▼
┌────────────────────────────────────────────────────────────────────┐
│                        Infrastructure Layer                         │
│  Document Access • ZIP Streaming • File Staging • SQLite/GRDB     │
│  PhotoKit • PHAssetResourceManager • CryptoKit • AVFoundation     │
│  ImageIO • OSLog • Background task wrapper (non-core)             │
└────────────────────────────────────────────────────────────────────┘
```

## 4.3 Runtime stages

The app should execute in the following runtime phases:

1. Permission gate
2. Source selection
3. Export discovery
4. Scan and manifest creation
5. Health scoring and user option selection
6. Library index build / refresh
7. Duplicate candidate generation
8. Import plan finalization
9. Batch import execution
10. Duplicate review queue generation
11. Completion report
12. Cleanup

## 4.4 Architectural boundaries

### UI must not perform parsing or PhotoKit mutations directly

The UI layer can trigger actions, show progress, and render state, but it should not own import logic or metadata decisions.

### Import orchestration should be single-owner

A single `ImportCoordinator` should own session transitions and checkpointing. Avoid multiple components independently mutating session state.

### Persistence should be explicit and queryable

All session and item-level state should live in a local database rather than being hidden in scattered files or in-memory objects.

### Heavy work should be actor-isolated

Parsing, dedupe, and import batch execution should run in isolated actors or serial execution contexts to avoid race conditions in resumable state.

# 5. Module breakdown

## 5.1 App Shell

**Responsibility:** app launch, environment setup, dependency wiring, top-level navigation, permission gate bootstrap.

**Contains:**
- app entry point
- dependency container
- app state store
- root navigation shell

**Does not contain:**
- parsing logic
- dedupe logic
- PhotoKit write logic

## 5.2 Permission and Privacy Module

**Responsibility:** request and validate required access, show privacy explanation, block unsupported authorization states.

**Key behaviors:**
- request `.readWrite` Photo library access
- detect limited access and block v1
- explain why full access is required
- offer user path back to Settings

**Output:**
- `photosAccessStatus`
- `authorizationGateState`

## 5.3 Source Intake Module

**Responsibility:** acquire the user-selected ZIP or folder via Files/document picker, hold security-scoped access, validate supported input shape.

**Key behaviors:**
- open ZIP or folder using document picker
- start security-scoped access
- validate that the selected item looks like an official export
- persist source bookmark / source reference where appropriate for the active session only
- cleanly stop security-scoped access when safe

**Output:**
- `ImportSource`

## 5.4 Export Discovery and ZIP Access Module

**Responsibility:** inspect the source structure and provide a normalized file enumeration interface to upstream parsing code.

**Key behaviors:**
- detect whether source is ZIP or folder
- expose file enumeration abstraction
- support lazy read / extract
- avoid eager extraction of the full archive
- support random access to manifest files and media payloads

**Output:**
- `ExportContainer`
- file locator interface
- staged extraction requests

## 5.5 Parser Module

**Responsibility:** parse the Snapchat export into normalized records.

**Key behaviors:**
- locate manifest files
- parse memory records
- map records to media paths
- normalize timestamps
- normalize location
- assign metadata confidence
- produce missing / invalid references

**Output:**
- normalized `ParsedMemoryRecord` rows
- parse issues
- health metrics

## 5.6 Metadata Resolver Module

**Responsibility:** determine the final metadata values to use for import.

**Key behaviors:**
- apply source-of-truth hierarchy
- choose final creation date
- choose final location or nil
- choose timezone normalization result
- assign confidence level and fallback reason

**Output:**
- `ResolvedMetadata`

## 5.7 Session Store Module

**Responsibility:** durable storage for session state, per-item progress, checkpoints, dedupe decisions, failure reasons.

**Key behaviors:**
- schema migrations
- transaction-safe updates
- query support for UI and resume engine
- durable session checkpoint writes

**Output:**
- canonical local truth for all import state

## 5.8 Library Indexer Module

**Responsibility:** build and maintain a local index of relevant properties from the user’s Photos library to support duplicate candidate generation.

**Key behaviors:**
- fetch PHAssets under full access
- capture coarse dedupe attributes
- persist index incrementally
- refresh stale portions when needed
- distinguish app-imported assets from pre-existing library assets where possible

**Output:**
- `LibraryAssetIndex`

## 5.9 Duplicate Engine

**Responsibility:** identify exact and suspected duplicate relationships between import candidates and library assets.

**Key behaviors:**
- generate candidate groups using coarse matching
- perform exact fingerprint verification where feasible
- perform near-match / perceptual / semantic-ish verification for suspected duplicates
- label confidence and reason
- build review queue

**Output:**
- `DuplicateCandidate`
- `DuplicateReviewItem`

## 5.10 Import Planner Module

**Responsibility:** turn parsed records, resolved metadata, and dedupe outputs into the concrete work plan for import.

**Key behaviors:**
- filter unsupported items
- skip exact duplicates when configured
- tag suspected duplicates for optional review
- assign batch order
- stage strict vs best-effort rules
- define album placement rules

**Output:**
- `ImportPlan`
- ordered import work items

## 5.11 Photos Writer Module

**Responsibility:** write assets into Photos and assign them to the master album.

**Key behaviors:**
- create / fetch master album
- save photos and videos with metadata application strategy
- map imported local identifiers back into session records
- handle PhotoKit mutation errors
- batch work to reduce risk of long uncheckpointed runs

**Output:**
- successful imported asset IDs
- failed writes with reasons

## 5.12 Resume Engine

**Responsibility:** recover an interrupted session and continue from the last clean checkpoint.

**Key behaviors:**
- inspect session state
- identify unfinished and retryable items
- rebuild in-memory work queue from database
- avoid duplicate writes after interruption
- continue deterministically

**Output:**
- resumed import execution plan

## 5.13 Cleanup Manager

**Responsibility:** delete staged temp files and close session resources safely.

**Key behaviors:**
- delete per-item staged media once safely imported if policy allows
- keep minimum evidence needed for report / resume until session completion
- remove security-scoped references
- purge old completed session temp data

**Output:**
- reduced disk footprint
- predictable lifecycle

## 5.14 Diagnostics Module

**Responsibility:** collect privacy-safe local operational records and generate support/debug exports.

**Key behaviors:**
- structured local logs
- redacted error codes
- stage-level timing
- import summary export
- no media content in diagnostics export

**Output:**
- local diagnostic bundle
- human-readable completion summary

# 6. Data model and local database schema

## 6.1 Persistence recommendation

Use SQLite with a strong query layer rather than a purely object-graph model. The importer needs:

- deterministic migrations
- batch updates
- efficient filtering
- resumability
- precise indexing
- support for large item counts

A thin SQLite wrapper or GRDB-style setup is a strong fit for this workload.

## 6.2 Core tables

### `import_sessions`

One row per user import session.

| Field | Type | Notes |
|---|---|---|
| id | UUID / TEXT PK | session identifier |
| created_at | DATETIME | session creation time |
| updated_at | DATETIME | session last update |
| state | TEXT | created, scanning, scanned, planning, importing, reviewing, completed, failed, canceled |
| mode | TEXT | best_effort or strict |
| source_type | TEXT | zip or folder |
| source_display_name | TEXT | user-facing name |
| source_bookmark_blob | BLOB nullable | optional security-scoped bookmark if used |
| master_album_local_id | TEXT nullable | Photos album identifier |
| total_records | INTEGER | parsed total |
| importable_records | INTEGER | eligible total |
| imported_count | INTEGER | successful count |
| skipped_exact_duplicate_count | INTEGER | skipped exact dupes |
| suspected_duplicate_count | INTEGER | review queue count |
| failed_count | INTEGER | failed items |
| health_score | INTEGER | 0–100 score |
| requires_full_access | INTEGER | always true in v1 |
| strict_mode_enabled | INTEGER | boolean |
| completed_at | DATETIME nullable | completion time |

### `session_checkpoints`

Stores durable progress checkpoints.

| Field | Type | Notes |
|---|---|---|
| id | UUID / TEXT PK | checkpoint id |
| session_id | FK | owning session |
| stage | TEXT | scan, dedupe, import, cleanup |
| sequence_no | INTEGER | ordered checkpoint number |
| payload_json | TEXT | compact checkpoint snapshot |
| created_at | DATETIME | timestamp |

### `parsed_records`

Canonical parsed rows derived from the Snapchat export.

| Field | Type | Notes |
|---|---|---|
| id | UUID / TEXT PK | internal row id |
| session_id | FK | owning session |
| source_record_key | TEXT | stable key from export if available |
| media_type | TEXT | image or video |
| manifest_media_path | TEXT | media path from export |
| staged_relative_path | TEXT nullable | local staged file path if extracted |
| original_filename | TEXT nullable | filename from export |
| export_timestamp_raw | TEXT nullable | raw timestamp |
| export_timezone_raw | TEXT nullable | raw timezone if present |
| export_latitude | REAL nullable | raw location |
| export_longitude | REAL nullable | raw location |
| export_duration_seconds | REAL nullable | for video |
| parse_status | TEXT | parsed, missing_media, invalid_manifest, unsupported |
| parse_issue_code | TEXT nullable | reason if not parsed cleanly |
| created_at | DATETIME | row creation time |

### `resolved_metadata`

Resolved import metadata for each parsed record.

| Field | Type | Notes |
|---|---|---|
| parsed_record_id | PK/FK | one-to-one with parsed record |
| final_creation_date | DATETIME nullable | final chosen creation date |
| final_timezone | TEXT nullable | normalized timezone |
| final_latitude | REAL nullable | final location |
| final_longitude | REAL nullable | final location |
| metadata_source | TEXT | export, embedded, file_timestamp, fallback |
| confidence_level | TEXT | high, medium, low |
| fallback_reason | TEXT nullable | why fallback was used |
| resolution_notes | TEXT nullable | internal notes |

### `library_asset_index`

Coarse index of user library assets for dedupe candidate generation.

| Field | Type | Notes |
|---|---|---|
| asset_local_id | TEXT PK | PHAsset localIdentifier |
| media_type | TEXT | image or video |
| creation_date | DATETIME nullable | PHAsset creation date |
| duration_seconds | REAL nullable | for video |
| pixel_width | INTEGER nullable | dimensions |
| pixel_height | INTEGER nullable | dimensions |
| location_lat_bucket | INTEGER nullable | coarse bucket for matching |
| location_lon_bucket | INTEGER nullable | coarse bucket for matching |
| favorite_flag | INTEGER nullable | optional, not core |
| source_hint | TEXT nullable | app_import or preexisting if known |
| fingerprint_status | TEXT | none, queued, exact, perceptual_only |
| exact_fingerprint | TEXT nullable | hash if computed |
| perceptual_fingerprint | TEXT nullable | compact phash if computed |
| indexed_at | DATETIME | last index update |

### `duplicate_candidates`

Stores dedupe outcomes.

| Field | Type | Notes |
|---|---|---|
| id | UUID / TEXT PK | candidate id |
| session_id | FK | owning session |
| parsed_record_id | FK | import item |
| library_asset_local_id | TEXT | matched library asset |
| match_type | TEXT | exact or suspected |
| confidence_score | REAL | 0–1 |
| match_reason | TEXT | exact_hash, strong_metadata, perceptual_match, etc |
| action_state | TEXT | pending_review, skip_import, keep_both, delete_library_item, ignore |
| created_at | DATETIME | created time |
| resolved_at | DATETIME nullable | reviewed time |

### `import_plan_items`

Concrete import work queue.

| Field | Type | Notes |
|---|---|---|
| id | UUID / TEXT PK | plan row |
| session_id | FK | owning session |
| parsed_record_id | FK | import item |
| batch_no | INTEGER | execution batch |
| planned_action | TEXT | import, skip_exact_duplicate, hold_for_review, fail_preflight |
| execution_state | TEXT | queued, staging, importing, imported, skipped, failed |
| album_name | TEXT | usually master album |
| imported_asset_local_id | TEXT nullable | result from Photos |
| execution_error_code | TEXT nullable | failure code |
| execution_error_message | TEXT nullable | compact message |
| updated_at | DATETIME | row update time |

### `review_queue_items`

UI-specific review units for duplicate review.

| Field | Type | Notes |
|---|---|---|
| id | UUID / TEXT PK | review id |
| session_id | FK | session |
| parsed_record_id | FK | candidate import asset |
| primary_library_asset_local_id | TEXT | most relevant duplicate |
| review_kind | TEXT | suspected_duplicate or confirmed_duplicate |
| recommended_action | TEXT | keep_both or skip_import |
| user_action | TEXT nullable | skip_import, keep_both, delete_library_asset |
| reviewed_at | DATETIME nullable | timestamp |

### `import_failures`

Detailed failure registry.

| Field | Type | Notes |
|---|---|---|
| id | UUID / TEXT PK | failure row |
| session_id | FK | session |
| parsed_record_id | FK nullable | item if applicable |
| stage | TEXT | scan, dedupe, stage, import, cleanup |
| error_code | TEXT | normalized code |
| severity | TEXT | warning or error |
| retryable | INTEGER | boolean |
| details_json | TEXT nullable | structured local details |
| created_at | DATETIME | timestamp |

### `app_settings`

Global local settings.

| Field | Type | Notes |
|---|---|---|
| key | TEXT PK | setting key |
| value_json | TEXT | stored value |

## 6.3 Useful indexes

Add indexes for:

- `parsed_records(session_id, parse_status)`
- `resolved_metadata(confidence_level)`
- `library_asset_index(media_type, creation_date)`
- `library_asset_index(exact_fingerprint)`
- `duplicate_candidates(session_id, action_state)`
- `import_plan_items(session_id, execution_state, batch_no)`
- `review_queue_items(session_id, reviewed_at)`

## 6.4 Filesystem working directories

Use a predictable working directory layout inside app sandbox:

```text
AppSandbox/
  Working/
    Sessions/
      {session_id}/
        manifests/
        staged/
          images/
          videos/
        cache/
        reports/
```

Rules:

- never copy the full source ZIP into this directory by default
- stage only needed manifests and media
- make all staged paths session-relative
- allow safe purge by session ID

# 7. Parser design

## 7.1 Input contract

Supported v1 inputs:

1. official Snapchat export ZIP
2. extracted official Snapchat export folder

Unsupported in v1:

- arbitrary folders of media
- screenshots of Snapchat
- manual ad hoc user file collections
- direct login-based import

## 7.2 Parser strategy

The parser should be built around a resolver abstraction rather than hard-coded assumptions scattered through the codebase.

Recommended parser components:

- `ExportStructureResolver`
- `ManifestLocator`
- `ManifestDecoder`
- `MediaPathResolver`
- `MetadataNormalizer`
- `HealthScorer`

This matters because Snapchat may adjust export structure over time. If the export changes, the parser should fail in a contained part of the codebase.

## 7.3 Scan phases

### Phase 1: source validation

Goals:

- confirm source is accessible
- confirm supported type (ZIP or folder)
- detect if likely official export
- verify readable manifest candidate files
- fail fast on totally invalid input

### Phase 2: manifest discovery

Goals:

- identify the memories manifest and supporting files
- capture export-level metadata
- identify media root locations

### Phase 3: record decoding

Goals:

- decode each memory row into a normalized internal struct
- extract media path, timestamp, location, duration, and identifiers
- capture parse issues but do not stop the whole job on individual bad rows

### Phase 4: media resolution

Goals:

- resolve each record to an actual file in ZIP/folder
- mark missing references
- assign media type and stageability

### Phase 5: metadata resolution

Goals:

- finalize timestamp and location
- assign confidence level
- assign fallback source

### Phase 6: health scoring

Goals:

- produce user-facing health summary
- power the export health page
- determine warnings before import

## 7.4 Metadata hierarchy

Recommended source-of-truth order:

1. explicit timestamp/location from export manifest
2. embedded metadata from the media file
3. file timestamp from extracted file metadata
4. fallback derived from export context / import-time placeholder

Strict mode rule:
- only import items with sufficient metadata confidence and valid media resolution

Best-effort rule:
- import all media that can be resolved and written, even when metadata confidence is medium or low

## 7.5 Metadata confidence model

### High confidence

- manifest timestamp present and parseable
- media file resolves cleanly
- timezone not contradictory
- location present and parseable if available

### Medium confidence

- manifest partially present
- embedded metadata needed to fill gaps
- timezone normalization uncertain but bounded
- file path resolution required fallback logic

### Low confidence

- manifest missing key fields
- file timestamp used as fallback
- location missing or unusable
- timestamp inferred rather than explicitly present

This confidence level should drive both UI messaging and strict-mode inclusion.

## 7.6 Export health score

Use a composite health score from 0–100 for the scan result screen. Example weighting:

- manifest readability: 20
- media path resolution rate: 25
- timestamp coverage: 25
- location coverage: 10
- unsupported/corrupt item rate: 10
- dedupe readiness / file consistency: 10

Example buckets:

- 90–100: excellent
- 75–89: good
- 50–74: mixed
- below 50: fragile

The app should never pretend low-health exports are fully clean.

## 7.7 Parser output contract

At the end of scanning, the parser must produce:

- parsed record rows
- resolved metadata rows
- scan issues list
- aggregate health metrics
- a staging plan for importable items

# 8. Import pipeline

## 8.1 Pipeline overview

The importer should behave like a state machine with persisted transitions:

```text
created
  → awaiting_permission
  → awaiting_source
  → scanning
  → scanned
  → planning
  → dedupe_indexing
  → dedupe_matching
  → awaiting_review (optional)
  → importing
  → post_import_review (optional)
  → completed
  → cleanup
```

## 8.2 Step-by-step pipeline

### Step 1: full Photos permission gate

- request read/write access
- if access is limited, show blocking explainer
- if denied, show settings recovery flow
- proceed only when full access is granted

### Step 2: source selection

- let user pick ZIP or folder
- hold security-scoped access
- create `import_sessions` row
- persist source descriptor

### Step 3: source validation and scan

- create working session folder
- inspect source
- parse manifests
- populate `parsed_records` and `resolved_metadata`
- compute health score
- create first checkpoint

### Step 4: options lock

On the options screen, lock:

- best effort vs strict
- duplicate handling defaults
- whether exact duplicates are auto-skipped
- whether suspected duplicates are held for review
- confirm album destination

### Step 5: library index build / refresh

- fetch Photos library assets
- build or refresh coarse index
- avoid computing full expensive fingerprints for every asset
- persist coarse attributes to `library_asset_index`

### Step 6: duplicate candidate generation

- for each parsed record, generate coarse candidate set from library index
- compute exact or near-match verification only for narrowed candidates
- write results to `duplicate_candidates`
- mark exact duplicates for skip by default
- mark suspected duplicates for review queue

### Step 7: build import plan

- create `import_plan_items`
- assign batch numbers
- skip exact duplicates if default enabled
- hold suspected duplicates if review required before import
- finalize importable item set

### Step 8: duplicate review (optional pre-import)

If review-before-import is enabled:

- present suspected duplicates to user
- capture user decisions
- update `duplicate_candidates` and `review_queue_items`
- rebuild import plan for held items

### Step 9: staged import execution

For each batch:

1. extract / stage media item from source
2. verify media is readable
3. write to Photos
4. add imported asset to master album
5. persist imported asset local ID
6. checkpoint after batch success
7. purge staged file if safe

### Step 10: post-import duplicate review

After import, optionally surface:
- confirmed duplicates skipped
- suspected duplicates still unresolved
- deletion review queue for existing library items if user wants to clean up

### Step 11: completion report

Generate:
- imported count
- exact duplicates skipped
- suspected duplicates reviewed
- failures
- metadata fallback summary
- total duration
- open Photos CTA

### Step 12: cleanup

- remove staged files
- keep session summary
- release source access
- mark session completed

## 8.3 Batch sizing

Do not import the entire set as one transaction. Use batches sized for predictable checkpointing. Initial recommendation:

- small media batch size for photos: 25–50
- smaller batch size for videos: 5–15
- dynamic batch sizing if memory pressure or failures increase

## 8.4 Idempotency rules

An interrupted session must be restartable without creating duplicate imports.

Rules:
- never re-run already imported `import_plan_items`
- checkpoint imported asset IDs as soon as PhotoKit confirms success
- exact duplicates skipped in prior run remain skipped
- failed items can be retried individually or as retryable subsets

## 8.5 Foreground-primary behavior

The import engine should assume the user remains in-app for long stages. If the app is interrupted:

- persist progress immediately at batch boundaries
- surface resume prompt on next launch
- do not promise unlimited background continuation in v1

# 9. Dedupe strategy

## 9.1 Dedupe philosophy

Full-library dedupe is a v1 feature, but it must be engineered pragmatically. The goal is not to fully hash every user asset blindly at startup. The goal is to reliably identify strong duplicate candidates while keeping the app usable on a phone.

Use a multi-stage dedupe system.

## 9.2 Duplicate classes

### Exact duplicate

The import item and an existing library asset are considered the same underlying media with very high confidence.

Examples:
- exact content hash match
- exact video payload hash match
- exact image byte hash after canonical read

**Default action in v1:** skip import

### Suspected duplicate

The import item and an existing library asset are highly similar but not proven identical.

Examples:
- same media type, near-identical timestamp, same dimensions, same duration, and strong perceptual similarity
- same video length and similar keyframe hash, but not exact binary match

**Default action in v1:** queue for review

## 9.3 Recommended multi-stage algorithm

### Stage A: coarse library index

For all accessible PHAssets, index cheap fields:

- media type
- creation date
- duration
- pixel width / height
- coarse location buckets
- app-import provenance if known

This gives a searchable candidate base.

### Stage B: candidate narrowing

For each import record, query candidates using combinations such as:

- same media type
- creation date within tolerance window
- same or near dimensions
- same or near duration for video
- same location bucket if present

This should reduce the expensive comparison set dramatically.

### Stage C: exact verification

For narrowed candidates only:

- compute import-item exact fingerprint from staged source media
- compute candidate library fingerprint by reading asset resource data on demand
- if exact fingerprints match, classify as exact duplicate

### Stage D: suspected duplicate verification

If exact match fails but similarity is high:

- image: compute perceptual hash
- video: compute representative frame hash + metadata similarity
- assign confidence score
- classify as suspected duplicate when threshold met

## 9.4 Fingerprint recommendations

### Image exact fingerprint

Preferred:
- SHA-256 over canonical original image bytes as read from source

Fallback:
- SHA-256 over staged file bytes

### Image suspected fingerprint

- perceptual hash from resized grayscale image
- optionally combine with aspect ratio and timestamp proximity

### Video exact fingerprint

Preferred:
- SHA-256 over canonical video file bytes from staged source and candidate asset resource data

Fallback:
- file-size + duration + dimensions + leading-chunk hash + trailing-chunk hash
- only use fallback as "strong evidence," not perfect proof

### Video suspected fingerprint

- representative keyframe perceptual hash
- duration tolerance
- dimensions
- creation date tolerance

## 9.5 Review-only deletion policy

Deletion must be explicit and user-driven.

Rules:
- no auto-delete
- duplicate review queue must clearly show which item is in library vs which is from Snapchat import
- allow delete only after explicit user action
- use a dedicated review state and confirmation step for deletion

## 9.6 Suggested review actions

For each review item, support:

- Skip import
- Keep both
- Delete existing library item and import Snapchat version
- Decide later

The recommended default should be conservative:
- exact duplicate → skip import
- suspected duplicate → keep both unless user chooses otherwise

# 10. Page-by-page app flow with technical behavior

## 10.1 Screen 1 — Welcome / trust screen

**Purpose:** explain what the app does, what it does not do, and why it needs access.

**UI content:**
- one-sentence purpose
- privacy bullets
- no Snapchat login needed
- no cloud upload
- full Photos access required for full-library dedupe

**Technical behavior:**
- no heavy work
- initialize environment
- check prior resumable session

**CTA:**
- Continue

## 10.2 Screen 2 — Permission gate

**Purpose:** request full Photos access and block limited access.

**UI content:**
- why full access is required
- note that library-wide duplicate detection depends on it

**Technical behavior:**
- request `.readWrite`
- evaluate status
- if `.limited`, show blocker state
- if denied, show settings recovery

**CTA:**
- Grant Access
- Open Settings

## 10.3 Screen 3 — Select export

**Purpose:** let user pick ZIP or extracted official export folder.

**UI content:**
- picker button
- examples of supported source types
- note that official export only is supported

**Technical behavior:**
- launch document picker
- acquire security-scoped URL
- create session row

**CTA:**
- Choose Export

## 10.4 Screen 4 — Scanning / health progress

**Purpose:** show the parser working and prepare user for result quality.

**UI content:**
- progress stages
- counts discovered so far
- scan warnings as they emerge

**Technical behavior:**
- source validation
- manifest discovery
- parse records
- resolve metadata
- compute health metrics
- checkpoint scan state

## 10.5 Screen 5 — Export health summary

**Purpose:** give user confidence and explain quality before import.

**UI content:**
- total items found
- photos vs videos
- items with strong timestamp
- items with location
- missing/corrupt items
- health score
- notable warnings

**Technical behavior:**
- query session summary
- derive user-facing metrics from database

**CTA:**
- Continue to options

## 10.6 Screen 6 — Import options

**Purpose:** lock import behavior.

**UI content:**
- mode: best effort or strict
- exact duplicate handling
- suspected duplicate handling
- album destination summary

**Technical behavior:**
- update session mode
- persist options
- create planning checkpoint

**CTA:**
- Build Import Plan

## 10.7 Screen 7 — Dedupe indexing / plan building

**Purpose:** communicate the heavy planning step.

**UI content:**
- index progress
- candidate generation progress
- estimated work categories

**Technical behavior:**
- build library index
- run candidate narrowing
- compute exact / suspected matches as needed
- create `import_plan_items`

## 10.8 Screen 8 — Duplicate review (optional pre-import)

**Purpose:** let user resolve suspected duplicates before import if configured.

**UI content:**
- card stack or card-swipe inspired UI
- side-by-side comparison
- confidence badge
- reason for match
- action buttons

**Technical behavior:**
- persist one decision per item
- update plan state live
- never mutate Photos library until confirmation

**CTA:**
- Review Next
- Apply Decisions

## 10.9 Screen 9 — Import progress

**Purpose:** execute import and show trustworthy progress.

**UI content:**
- imported count
- skipped exact duplicates
- current item state
- failures so far
- pause / stop after current batch if supported

**Technical behavior:**
- batch execution
- per-item staging
- PhotoKit writes
- album assignment
- checkpoint persistence
- staged-file cleanup after safe commit

## 10.10 Screen 10 — Post-import duplicate cleanup (optional)

**Purpose:** optionally let user review delete candidates after import.

**UI content:**
- grouped duplicate cards
- explicit labeling of "existing library item" and "newly imported item"

**Technical behavior:**
- only present items eligible for deletion review
- delete only via explicit PhotoKit change request
- log deletion results

## 10.11 Screen 11 — Completion / success report

**Purpose:** close the job cleanly and prove what happened.

**UI content:**
- imported count
- exact duplicates skipped
- suspected duplicates resolved
- failed items summary
- metadata fallback summary
- open Photos button
- cleanup temp files status

**Technical behavior:**
- mark session completed
- finalize report
- release source references where safe

## 10.12 Screen 12 — Resume session (conditional)

**Purpose:** recover interrupted work.

**UI content:**
- session summary
- what was already done
- what remains
- retryable failures

**Technical behavior:**
- rebuild work queue from checkpoint and plan state
- do not repeat completed writes

# 11. Edge cases and failure handling

## 11.1 Permission edge cases

### User grants limited access

**Behavior:** block progress and explain why full access is required.

### User denies access

**Behavior:** block import and offer Settings recovery.

### User revokes access mid-session

**Behavior:** stop import safely, checkpoint state, and mark session blocked.

## 11.2 Source edge cases

### Invalid ZIP

**Behavior:** fail scan with explicit unsupported/corrupt source message.

### ZIP opens but expected manifest missing

**Behavior:** fail scan with "unsupported export structure" message and log.

### Folder import missing media referenced by manifest

**Behavior:** continue scan, mark item-level warnings, reduce health score.

### User loses access to source URL mid-session

**Behavior:** pause session and require source re-selection if resume cannot reopen.

## 11.3 Metadata edge cases

### Timestamp missing

**Behavior:** best effort uses fallback hierarchy; strict mode excludes item.

### Timestamp parseable but timezone ambiguous

**Behavior:** normalize conservatively, mark medium confidence.

### Location malformed

**Behavior:** drop location, keep importable if other metadata is acceptable.

### Mixed media without duration or dimensions

**Behavior:** still import if readable; dedupe confidence decreases.

## 11.4 Storage edge cases

### Device storage too low before scan

**Behavior:** fail preflight with space warning.

### Storage too low during staging

**Behavior:** pause import, checkpoint, surface storage recovery message.

### Very large video causes memory pressure

**Behavior:** use streamed reads, reduce batch size dynamically, mark item retryable if needed.

## 11.5 Dedupe edge cases

### Huge photo library makes indexing slow

**Behavior:** show explicit stage progress and avoid exact hashing of all assets.

### iCloud-backed library asset not immediately local

**Behavior:** allow delayed candidate verification, degrade to suspected duplicate if exact verification cannot complete promptly, or queue for later review.

### Multiple library assets match one import item

**Behavior:** keep one primary review item but preserve all candidate references in details.

### Duplicate confidence unclear

**Behavior:** classify as suspected, never exact.

## 11.6 Import execution edge cases

### App terminates mid-batch

**Behavior:** last clean checkpoint wins; partially completed items are re-evaluated carefully.

### PhotoKit write succeeds but app crashes before local DB update

**Behavior:** on resume, reconciliation step should inspect recently created assets if possible before re-importing. This is one of the reasons batch boundaries and immediate result persistence matter.

### Album creation fails

**Behavior:** retry once; if still failing, import to library and mark album assignment failure separately.

### Individual media file unreadable

**Behavior:** mark item failed and retryable if likely transient; otherwise failed and non-retryable.

## 11.7 Deletion review edge cases

### User attempts deletion without confidence

**Behavior:** require explicit confirmation and show whether item is exact or suspected.

### Delete succeeds for one asset in a candidate group and fails for another

**Behavior:** reflect partial completion and keep audit entry.

## 11.8 Resume edge cases

### User reopens app after days

**Behavior:** session can resume as long as source access and staged data are still recoverable.

### Working files were cleaned before resume

**Behavior:** rebuild from source if source remains accessible; otherwise prompt user to re-select export.

# 12. Recommended iOS stack and implementation approach

## 12.1 UI stack

**Recommendation:** SwiftUI for almost all screens, with a thin UIKit bridge where needed.

Why:
- rapid iteration
- good fit for state-driven progress and review screens
- easier founder-facing iteration on UX

Use UIKit wrappers only where necessary:
- document picker
- any lower-level interoperability screens

## 12.2 Data and persistence stack

**Recommendation:** SQLite-backed local store with explicit migrations.

Why:
- better control over large import sessions
- stronger resumability
- clearer debugging
- efficient indexing for duplicate candidate queries

A thin relational persistence layer is preferable to a vague object store for this problem.

## 12.3 Concurrency model

**Recommendation:** async/await with actor isolation for critical services.

Suggested isolated services:
- `ImportCoordinatorActor`
- `ParserActor`
- `LibraryIndexerActor`
- `DuplicateEngineActor`
- `PhotosWriterActor`

Avoid free-form concurrent writes to the database and Photos layer.

## 12.4 Media and system frameworks

Use:

- PhotoKit for library read/write and album management
- AVFoundation for video metadata and keyframe extraction
- ImageIO / CoreGraphics for image metadata and downscaled decode
- CryptoKit for exact hashing
- OSLog / Logger for structured local logs
- UniformTypeIdentifiers for file type handling
- UIKit document picker APIs for user-selected ZIP/folder access

## 12.5 ZIP handling

Because v1 must support official Snapchat ZIP exports and must avoid copying the whole ZIP first, use a ZIP reader that supports:

- stream-oriented access
- lazy extraction of individual entries
- predictable memory usage

Keep the ZIP abstraction behind a protocol so the implementation can be swapped later if needed.

## 12.6 Logging and diagnostics

Use structured local logs only.

Recommended principles:
- no media content in logs
- no precise location values in general logs unless explicitly needed in a local debug bundle
- normalize error codes
- produce a user-exportable report if support is ever needed

## 12.7 Testing approach

Minimum automated test layers:

1. parser unit tests with fixture exports
2. metadata resolution tests
3. import-plan builder tests
4. dedupe candidate generation tests
5. session resume tests
6. UI tests for key flows and permission blockers

## 12.8 Performance strategy

Key principles:

- stage only what is needed
- prefer streaming reads
- bound batch sizes
- checkpoint often
- persist coarse library index
- avoid full-library exact hashing in the first pass
- make heavy stages transparent to the user

# 13. Suggested project structure

```text
SnapImportApp/
  App/
    SnapImportApp.swift
    AppEnvironment.swift
    RootCoordinator.swift

  Features/
    Welcome/
    Permissions/
    SourcePicker/
    ScanHealth/
    ImportOptions/
    DedupeReview/
    ImportProgress/
    Completion/
    ResumeSession/

  Domain/
    Models/
    UseCases/
    Services/
    Policies/
    ValueObjects/

  Infrastructure/
    Persistence/
      Database.swift
      Migrations.swift
      Repositories/
    Files/
      DocumentAccess/
      ZipAccess/
      WorkingDirectory/
    Photos/
      PhotosAuthorizationService.swift
      PhotosLibraryService.swift
      PhotosWriter.swift
      AlbumService.swift
    Parsing/
      ExportStructureResolver.swift
      ManifestLocator.swift
      ManifestDecoder.swift
      MetadataNormalizer.swift
    Dedupe/
      LibraryIndexer.swift
      FingerprintService.swift
      PerceptualHashService.swift
      DuplicateEngine.swift
    Diagnostics/
      Logging.swift
      ReportBuilder.swift

  Shared/
    Extensions/
    Utilities/
    UIComponents/

  Tests/
    ParserTests/
    MetadataTests/
    DedupeTests/
    ImportPlanTests/
    ResumeTests/
    UITests/
```

# 14. Build order and implementation milestones

## Milestone 1 — App shell and permission gate

Deliver:
- root navigation
- trust screen
- full-access permission flow
- limited-access blocker
- source picker shell

## Milestone 2 — Export scan engine

Deliver:
- ZIP/folder intake abstraction
- manifest discovery
- record parsing
- metadata resolution
- export health screen

## Milestone 3 — Local session persistence

Deliver:
- SQLite schema
- migrations
- session lifecycle
- checkpoints
- resume screen shell

## Milestone 4 — Import planner and Photos writer

Deliver:
- import plan generation
- master album creation
- single-item and batched PhotoKit writes
- import progress screen

## Milestone 5 — Library index and exact duplicate skip

Deliver:
- coarse library index
- exact duplicate candidate narrowing
- default exact skip path
- completion report

## Milestone 6 — Suspected duplicate review

Deliver:
- candidate confidence scoring
- review queue
- card-based review UI
- explicit delete / keep / skip actions

## Milestone 7 — Hardening for 20 GB-class imports

Deliver:
- aggressive staging cleanup
- dynamic batch sizing
- failure recovery
- long-session QA
- storage pressure handling

# 15. Acceptance criteria for v1

## Functional acceptance criteria

The app is v1-ready when all of the following are true:

1. User can select an official Snapchat export ZIP or extracted official folder.
2. App blocks limited Photos access and requires full read/write access.
3. App can scan the export and show:
   - total items
   - photos vs videos
   - metadata health
   - missing/corrupt item count
4. App supports best-effort import and strict mode.
5. App can import media into Photos and place imported assets into one master album.
6. App can persist and resume interrupted sessions.
7. App can skip exact duplicates against the device library.
8. App can surface suspected duplicates for review.
9. App never auto-deletes media.
10. App generates a completion report with counts and failures.
11. Media never leaves the device.
12. App remains stable on large exports under the defined QA target.

## Quality acceptance criteria

1. No duplicate imports are created when resuming after interruption.
2. Per-item failure states are visible and retryable where appropriate.
3. Health and success screens are derived from real session data, not guessed values.
4. The app does not require the user to understand export internals.
5. The duplicate review UI clearly distinguishes library items from import items.
6. Temp file growth is bounded and predictable during import.

# 16. Open questions intentionally deferred

These are valid later decisions, but they do not block implementation:

- App Store pricing model
- whether to support year/month subalbums in v1.1
- whether to add separate duplicate cleanup mode after import
- whether to support a Mac companion target
- how much of the library index to cache across app launches
- whether to support user-exported debug bundles

# 17. Cursor handoff section

## 17.1 What Cursor should treat as the source of truth

When coding this app, Cursor should treat the following as non-negotiable:

- full Photos read/write access is required
- limited access is a blocker, not a fallback mode
- processing is on-device only
- official Snapchat export only
- ZIP must be processed from source without copying the full ZIP first
- importer must be resumable and idempotent
- exact duplicates are skipped by default
- suspected duplicates go to review
- deletion is review-only
- v1 uses one master album
- importer is foreground-primary

## 17.2 Architecture guidance for Cursor

Cursor should generate code using a layered architecture:

- UI layer does not own business logic
- import orchestration is centralized
- persistence is explicit and durable
- dedupe is multi-stage
- all heavy services should be testable in isolation

## 17.3 What Cursor should not do

- do not introduce a backend
- do not add user accounts
- do not use a simplistic one-shot import pipeline
- do not auto-delete duplicates
- do not silently degrade to limited Photos access
- do not assume small import sizes
- do not hard-code a single export filename in many places
- do not keep the whole ZIP extracted forever
- do not hide failures from the completion report

## 17.4 Suggested first implementation prompt for Cursor

Use this project brief:

> Build an iPhone-first Swift app called Snap Import that imports official Snapchat Memories exports into Apple Photos. The app requires full Photo library read/write access and must block limited access because v1 requires full-library dedupe. The app must process an official Snapchat export ZIP or extracted official export folder from a user-selected Files URL, and it must not first copy the full ZIP into app sandbox. Build the app with a layered architecture: SwiftUI presentation, centralized import coordinator, parser module, SQLite-backed session store, library indexer, duplicate engine, PhotoKit writer, and resumable import state machine. Default import mode is best effort, with strict mode optional. Exact duplicates should be skipped by default. Suspected duplicates should be queued for explicit review. Duplicate deletion is review-only; never auto-delete. The importer is foreground-primary and must be resumable and idempotent. v1 should create one master album in Photos. No backend, no cloud storage, and no media leaves the device.

## 17.5 Suggested second implementation prompt for Cursor

> Start by scaffolding the project structure, database schema, and core domain models. Implement the permission gate, source picker, session persistence, and scan pipeline before building the duplicate engine or PhotoKit writer. Ensure all core services are protocol-driven and testable.

## 17.6 Suggested build sequence for Cursor

1. app shell + permission flow
2. source intake
3. export parser
4. health summary
5. local database + session checkpoints
6. Photos writer + album creation
7. resumable import pipeline
8. coarse library index
9. exact dedupe
10. suspected duplicate review
11. completion report
12. hardening + tests

# 18. Final recommendation

This should be built as a premium-feeling, privacy-forward utility with a serious import core, not a hacky file transfer app. The founder advantage will not come from doing something magically new; it will come from making an annoying, fragile workflow feel trustworthy and correct.

That means the engineering bar for v1 is:

- solid parser boundaries
- explicit metadata confidence
- durable resumability
- conservative duplicate handling
- clean completion proof

If those are done well, the app will feel materially better than a one-off importer and will have a real foundation for later evolution.


# 19. Reference notes for engineering

These platform references informed the locked architecture decisions:

- Snapchat Support — “How do I download my data from Snapchat?”: confirms official My Data export flow, Memories-only export option, ZIP delivery, and note that larger downloads take longer and computer download may work better than mobile.
- Apple Developer — PhotoKit privacy and limited library access guidance: confirms `.readWrite` authorization flow and limited-library behavior.
- Apple Developer — `UIDocumentPickerViewController` / document picker guidance: confirms external picked files use security-scoped URLs.
- Apple Developer — BackgroundTasks guidance: confirms long-running background tasks are system-managed and should not be treated as guaranteed unrestricted execution.
- Apple Developer — PhotoKit / Photos write APIs: basis for album creation, asset creation, and explicit deletion review flow.
