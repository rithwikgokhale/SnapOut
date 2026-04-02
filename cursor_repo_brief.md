
# Snapchat Memories Import Utility — Repo Architecture Brief for Cursor

**Status:** Authoritative engineering and design brief for v1  
**Audience:** Founder, principal engineer, Cursor agents  
**Goal:** This file should live in the repo and act as the primary build context for Cursor.

---

## 0. How to use this file

This document is the single source of truth for:

- locked product and engineering decisions
- app architecture and module boundaries
- package structure and starter file tree
- design system and screen layout rules
- local data model and protocol surface
- implementation sequencing
- Cursor workflow instructions

Use this document in three stages:

1. **Understanding checkpoint**
   - Cursor reads this file and produces a restatement in Markdown and JSON.
   - We review that output before allowing code generation.

2. **Shell milestone**
   - Cursor sets up packages, design system, DI, navigation shell, protocol layer, placeholder screens, and database scaffolding.

3. **Implementation milestones**
   - Cursor builds the import pipeline, parser, dedupe, PhotoKit integration, and review flows in a controlled order.

This file is intentionally opinionated. Do not allow Cursor to improvise architecture or package boundaries without first updating this document.

---

## 1. Product summary

The app is an **iPhone-first, privacy-first Snapchat Memories import utility**.

It exists to help a user take the **official Snapchat Memories export**, scan it, restore metadata, import into Apple Photos, identify duplicate candidates against the on-device library, and present a clean and trustworthy post-import result.

This is **not** a social app, slideshow app, cloud backup service, or general media manager in v1.

### Core promise

> Import official Snapchat Memories into Apple Photos accurately, privately, and safely, while restoring dates, preserving available locations, and preventing duplicate chaos.

---

## 2. Locked decisions

These are already decided. Treat them as constraints, not ideas.

### 2.1 Platform and scope

- **Primary platform:** iPhone first
- **Future extensibility:** core logic should be reusable by a future Mac target
- **No Android planning in v1**
- **No live Snapchat sync**
- **No backend, no cloud media storage, no account system**
- **On-device processing only**

### 2.2 Input and permissions

- **Input source:** official Snapchat export only
- **Accepted forms:** official export ZIP or extracted official export folder
- **Photos access:** full Photos `.readWrite` access is required
- **Limited Photos access is not sufficient for v1**
- If the user grants limited access, block and explain why full access is required for full-library dedupe and safe import behavior

### 2.3 Import and pipeline behavior

- **Default import mode:** Best Effort
- **Optional mode:** Strict Mode
- **Processing strategy:** stream/process from the picked source; do not first copy the entire ZIP into sandbox
- **Execution model:** foreground-primary
- **Recovery model:** resumable and idempotent
- **Album strategy:** one master album in v1
- **Scale target:** engineer for large imports, with **20 GB as the design target**
- **Target class:** modern iPhones with sufficient free space

### 2.4 Dedupe behavior

- **Dedupe scope:** full on-device photo library
- **Duplicate deletion in v1:** review-only
- **No auto-delete**
- Duplicate review can have a swipeable interaction style, but it must remain deliberate and not gamified
- Support both:
  - **confirmed duplicates**
  - **suspected duplicates**

### 2.5 Privacy and UX stance

The product and app design should repeatedly communicate:

- no Snapchat login required
- no backend processing
- no cloud storage
- no media leaving the device
- one clear utility purpose
- explicit user review before destructive actions

---

## 3. Non-goals for v1

These are out of scope:

- slideshow generation
- face recognition
- people clustering
- cross-platform sync
- iCloud service features
- social sharing features
- cloud backup
- collaboration
- automatic duplicate deletion
- backend analytics on media or location data
- general “organize all my photos” product expansion

---

## 4. Engineering principles

These principles should guide tradeoffs.

### 4.1 Private by construction

Everything should work on-device. Remote services are not part of the architecture. Any diagnostics should be local, redacted, and optionally user-exported manually.

### 4.2 Manifest-first, not folder-first

Treat the Snapchat export as a structured manifest-driven import job. Parse metadata first, validate health, build an import plan, then execute.

### 4.3 Stream over copy

Do not duplicate the entire input ZIP into app storage before starting. Work from the source URL and only materialize what is needed in a managed working directory.

### 4.4 Durable state machine

Import is not a one-shot button press. It is a durable state machine with persistent progress and restart safety.

### 4.5 Safety beats cleverness

No auto-delete. No hidden best guesses without labeling confidence. No destructive operations without explicit user review.

### 4.6 Isolate framework edges

All PhotoKit, file access, ZIP access, and persistence concerns should be isolated behind protocols and module boundaries.

### 4.7 UI should show its work

The app should always be able to explain:
- what it found
- what it plans to do
- what it imported
- what it skipped
- what failed
- what the user should do next

---

## 5. Tech stack decisions

These are approved decisions for v1.

### 5.1 Package manager

- **Swift Package Manager**

Use SPM for both third-party dependencies and internal modularization.

### 5.2 Database layer

- **GRDB**

Use GRDB for the local SQLite-backed persistence layer:
- import sessions
- asset manifests
- duplicate candidates
- import progress
- retry state
- deletion review queue
- diagnostics / summaries

### 5.3 ZIP handling

- **ZIPFoundation**

Use ZIPFoundation for standard ZIP handling. The app input is a standard ZIP export, not Apple Archive format.

### 5.4 UI stack

- **SwiftUI**
- native iOS navigation
- Observation / Observable view models
- thin view layer
- logic in services, engines, coordinators, and view models

### 5.5 Apple frameworks

- PhotoKit
- UniformTypeIdentifiers
- Security-scoped resource APIs
- AVFoundation / ImageIO as needed for media inspection
- CryptoKit for hashing if needed
- OSLog for local operational logging

---

## 6. Recommended repo layout

Place this file in the repo under `docs/` or `architecture/`.

Recommended path:

```text
docs/cursor_repo_brief.md
```

Recommended project shape:

```text
SnapImportApp/
├── App/
│   ├── SnapImportApp.swift
│   ├── AppCoordinator.swift
│   ├── RootNavigation.swift
│   ├── DependencyContainer.swift
│   └── AppEnvironment.swift
├── Packages/
│   ├── AppCore/
│   ├── DomainModels/
│   ├── DesignSystem/
│   ├── Persistence/
│   ├── ZipAccess/
│   ├── PhotosAccess/
│   ├── ImportEngine/
│   ├── DedupeEngine/
│   ├── Diagnostics/
│   ├── FeatureWelcome/
│   ├── FeaturePermissions/
│   ├── FeatureImportSource/
│   ├── FeatureExportHealth/
│   ├── FeatureImportOptions/
│   ├── FeatureImportProgress/
│   ├── FeatureDuplicateReview/
│   ├── FeatureImportSuccess/
│   ├── FeatureSettings/
│   └── SharedTestSupport/
├── docs/
│   └── cursor_repo_brief.md
└── SnapImportApp.xcodeproj
```

### Why this structure exists

- to keep the core reusable for a future Mac target
- to isolate third-party and Apple framework boundaries
- to prevent feature screens from directly accumulating business logic
- to give Cursor clear package/module responsibilities

---

## 7. Module responsibilities

### 7.1 App

Owns:
- app entry point
- app-level dependency composition
- root navigation
- feature assembly
- environment wiring

Should **not** own:
- parsing logic
- database schema
- PhotoKit calls
- ZIP processing
- dedupe logic

### 7.2 DomainModels

Pure shared models, enums, value types, and protocol-facing DTOs.

Should contain:
- `ImportSession`
- `ImportAsset`
- `ParsedSnapRecord`
- `ImportPhase`
- `ImportMode`
- `MetadataConfidence`
- `DuplicateCandidate`
- `DuplicateConfidence`
- `LibraryAssetReference`
- `ImportFailureReason`
- `ExportHealthReport`
- `ImportSummary`
- `PhotosAccessRequirement`

Should **not** import:
- SwiftUI
- GRDB
- PhotoKit
- ZIPFoundation

### 7.3 DesignSystem

Owns:
- color tokens
- typography tokens
- spacing/radius tokens
- shared components
- empty/loading/error states
- layout shell helpers

Should contain:
- `AppColor`
- `AppText`
- `AppSpacing`
- `AppRadius`
- `PrimaryButton`
- `SecondaryButton`
- `DestructiveButton`
- `SectionCard`
- `StatCard`
- `HealthSummaryCard`
- `ProgressCard`
- `IssueCard`
- `InfoRow`
- `SettingsRow`
- `StatusBadge`
- `MetadataConfidenceBadge`
- `PermissionExplainerView`
- `EmptyStateView`
- `ErrorStateView`
- `LoadingStateView`

### 7.4 Persistence

Owns GRDB and the local database.

Responsibilities:
- DB initialization
- migrations
- import session persistence
- asset manifest persistence
- duplicate candidate persistence
- diagnostics and failure persistence
- resumability checkpoints

Expose stores/repositories through protocols.

### 7.5 ZipAccess

Owns all ZIPFoundation usage and security-scoped file access.

Responsibilities:
- open picked ZIP/folder
- enumerate archive entries
- targeted extraction
- temporary extraction management
- source URL access lifecycle

This package should know nothing about PhotoKit.

### 7.6 PhotosAccess

Owns all PhotoKit integration.

Responsibilities:
- permission checks and prompts
- album create/fetch logic
- library reads for dedupe candidate narrowing
- asset imports/saves
- duplicate review deletion actions
- full-access enforcement

This package should be the only package touching PhotoKit directly.

### 7.7 ImportEngine

Owns the core import orchestration.

Responsibilities:
- source scanning
- export parsing coordination
- validation / health report generation
- metadata normalization
- import planning
- chunked import execution
- resumability
- phase transitions
- completion summaries

Think of this as the local backend of the app.

### 7.8 DedupeEngine

Owns duplicate analysis.

Responsibilities:
- build candidate sets
- compare import assets to library assets
- exact match rules
- suspected match rules
- scoring and reasoning
- output review queue material

Should not own delete actions. Deletion belongs to `PhotosAccess`.

### 7.9 Diagnostics

Owns local logs, summaries, and human-readable diagnostic material.

Responsibilities:
- structured local logs
- diagnostic export models
- user-visible summaries
- redacted support bundles if later needed

### 7.10 Feature packages

Each feature package owns:
- SwiftUI screen(s)
- view model(s)
- feature-specific view state
- local mapping from domain -> presentation
- navigation hooks

Feature packages should depend on:
- `DesignSystem`
- `DomainModels`
- relevant service protocols
- `AppCore`

Not directly on low-level implementation packages unless required by the composition layer.

### 7.11 AppCore

Composition and service protocol surface.

Responsibilities:
- service protocols
- use case interfaces
- dependency composition helpers
- module assembly contracts

This should give feature packages protocol-based access to:
- import orchestration
- permissions state
- export scanning
- duplicate review actions
- diagnostic summaries

---

## 8. Dependency graph

Keep dependency direction clean.

```text
App
├── AppCore
├── Feature*
├── DesignSystem
└── DomainModels

Feature*
├── AppCore
├── DesignSystem
└── DomainModels

AppCore
├── DomainModels
├── Persistence
├── ZipAccess
├── PhotosAccess
├── ImportEngine
├── DedupeEngine
└── Diagnostics

ImportEngine
├── DomainModels
├── ZipAccess (protocol-facing)
├── Persistence (protocol-facing)
├── PhotosAccess (protocol-facing)
├── DedupeEngine (protocol-facing)
└── Diagnostics (protocol-facing)

Persistence
├── DomainModels
└── GRDB

ZipAccess
└── ZIPFoundation

PhotosAccess
└── PhotoKit
```

Hard rule:
- UI packages do not directly reach into PhotoKit, GRDB, or ZIPFoundation
- DomainModels remains framework-light and reusable
- all framework-heavy integrations are isolated

---

## 9. Design system spec

### 9.1 Visual direction

The product should feel:

- private
- calm
- high-trust
- native to iPhone
- utility-first
- not flashy

Avoid:
- loud gradients
- bright Snapchat-adjacent branding
- social-media styling
- whimsical illustrations in core flows

### 9.2 Color system

Use semantic tokens, not raw colors in feature code.

#### Semantic tokens

- `accent`
- `success`
- `warning`
- `error`
- `backgroundPrimary`
- `backgroundSecondary`
- `surfacePrimary`
- `surfaceSecondary`
- `textPrimary`
- `textSecondary`
- `textTertiary`
- `borderSubtle`
- `borderStrong`

#### Recommended mapping

- accent: restrained blue or indigo
- success: system green
- warning: system orange / amber
- error: system red
- backgrounds/surfaces/text: iOS system colors

### 9.3 Typography

Use **SF Pro only**.

Recommended roles:
- `largeTitle`
- `title`
- `titleEmphasis`
- `sectionHeader`
- `body`
- `bodyEmphasis`
- `subheadline`
- `footnote`
- `caption`
- `monospacedMeta`

### 9.4 Spacing

Fixed scale:

- `xs = 4`
- `sm = 8`
- `md = 12`
- `lg = 16`
- `xl = 20`
- `xxl = 24`
- `xxxl = 32`

### 9.5 Radius

- small: 8
- medium: 12
- large: 16
- xlarge: 20

### 9.6 Icons

Use **SF Symbols only**.

### 9.7 Screen layout rules

Standard screen template:

1. navigation title
2. short instructional subtitle
3. main content cards
4. persistent bottom CTA bar where appropriate

Rules:
- one primary action per screen
- destructive actions require context and confirmation
- do not bury critical CTAs deep in scrolling content
- health/progress/review screens should feel analytical and deliberate

---

## 10. Screen map

### 10.1 WelcomeScreen

Purpose:
- explain what the app does
- reinforce privacy promise
- direct user to the import flow

### 10.2 PermissionsScreen

Purpose:
- explain why full Photos access is required
- show that no cloud or backend is involved
- block until full access is granted

### 10.3 ImportSourceScreen

Purpose:
- pick ZIP or extracted folder
- explain official export requirement
- start source scanning

### 10.4 ExportHealthScreen

Purpose:
- show scan results
- show counts and validation summaries
- expose issues before import starts

Expected content:
- total media found
- matched entries
- items with usable timestamps
- items with location data
- missing file references
- duplicate candidate pre-summary if available
- recommended next action

### 10.5 ImportOptionsScreen

Purpose:
- choose Best Effort vs Strict Mode
- confirm dedupe behavior
- confirm import plan
- show master album destination

### 10.6 ImportProgressScreen

Purpose:
- show phase
- show progress
- reassure user that import is resumable
- show current counts

### 10.7 DuplicateReviewScreen

Purpose:
- review suspected/confirmed duplicates
- keep, skip, or queue for later
- never auto-delete

### 10.8 ImportSuccessScreen

Purpose:
- summarize results
- show imported count
- show duplicates skipped or queued
- show failures
- offer open Photos
- offer cleanup temp files

### 10.9 SettingsScreen

Purpose:
- show local-only/privacy posture
- import defaults
- diagnostics export if supported later
- cleanup working files

---

## 11. Core data model

These are the important domain entities and persisted models.

### 11.1 `ImportSession`

Represents one end-to-end import attempt.

Suggested fields:
- `id`
- `createdAt`
- `updatedAt`
- `sourceType` (zip/folder)
- `sourceBookmarkData` or source reference
- `displayName`
- `status`
- `phase`
- `importMode`
- `healthSummarySnapshot`
- `startedAt`
- `completedAt`
- `cancelledAt`
- `totalDiscoveredCount`
- `plannedImportCount`
- `successfulImportCount`
- `skippedCount`
- `failureCount`
- `requiresUserAction`
- `cleanupState`

### 11.2 `ParsedSnapRecord`

Represents one logical Snapchat export record after parsing.

Suggested fields:
- `id`
- `sessionId`
- `sourceRecordIdentifier`
- `relativeMediaPath`
- `mediaType`
- `snapchatTimestamp`
- `embeddedTimestamp`
- `normalizedTimestamp`
- `locationLatitude`
- `locationLongitude`
- `locationSource`
- `metadataConfidence`
- `rawChecksumHint`
- `validationStatus`

### 11.3 `ImportAsset`

Represents one importable asset after planning.

Suggested fields:
- `id`
- `sessionId`
- `parsedRecordId`
- `resolvedSourcePath`
- `workingFilePath`
- `mediaType`
- `normalizedTimestamp`
- `location`
- `confidence`
- `contentHash`
- `byteSize`
- `duration`
- `pixelWidth`
- `pixelHeight`
- `importStatus`
- `failureReason`
- `photosLocalIdentifier` (if saved)

### 11.4 `LibraryAssetReference`

Represents a narrowed view of a library asset used for dedupe.

Suggested fields:
- `id`
- `photosLocalIdentifier`
- `creationDate`
- `mediaType`
- `duration`
- `pixelWidth`
- `pixelHeight`
- `byteSizeHint`
- `fingerprint`
- `albumMembershipHint`

### 11.5 `DuplicateCandidate`

Represents a potential duplicate relationship.

Suggested fields:
- `id`
- `sessionId`
- `importAssetId`
- `libraryAssetLocalIdentifier`
- `confidence`
- `reasonCode`
- `score`
- `reviewStatus`
- `userDecision`
- `createdAt`
- `resolvedAt`

### 11.6 `ImportFailure`

Suggested fields:
- `id`
- `sessionId`
- `importAssetId`
- `phase`
- `reason`
- `detail`
- `retryEligible`
- `createdAt`

### 11.7 Supporting enums

Important enums:
- `ImportMode`
- `ImportPhase`
- `ImportSessionStatus`
- `MetadataConfidence`
- `DuplicateConfidence`
- `DuplicateReasonCode`
- `ImportFailureReason`
- `CleanupState`
- `PermissionsState`

---

## 12. Persistence schema outline

Use GRDB migrations from day one.

Suggested tables:
- `import_sessions`
- `parsed_snap_records`
- `import_assets`
- `library_asset_cache`
- `duplicate_candidates`
- `import_failures`
- `diagnostic_events`
- `app_settings`

Notes:
- store denormalized counts on `import_sessions` for cheap progress rendering
- keep foreign keys clear and indexed
- add indexes for:
  - `sessionId`
  - `normalizedTimestamp`
  - `importStatus`
  - `reviewStatus`
  - `confidence`
  - `photosLocalIdentifier`

---

## 13. Starter protocol surface

These are the starter protocols Cursor should scaffold early. Names can be adjusted slightly, but the responsibilities should remain.

### 13.1 Source / ZIP access

```swift
public protocol ImportSourceAccessing {
    func openSource(url: URL) async throws -> ImportSourceHandle
    func closeSource(_ handle: ImportSourceHandle) async
    func listEntries(in handle: ImportSourceHandle) async throws -> [ImportSourceEntry]
    func extractEntry(
        _ entry: ImportSourceEntry,
        from handle: ImportSourceHandle,
        to destinationURL: URL
    ) async throws -> URL
    func fileExists(
        at relativePath: String,
        in handle: ImportSourceHandle
    ) async throws -> Bool
}
```

### 13.2 Export parsing

```swift
public protocol SnapchatExportParsing {
    func scanSource(_ source: ImportSourceHandle) async throws -> ExportScanResult
    func parseExport(_ source: ImportSourceHandle) async throws -> [ParsedSnapRecord]
}
```

### 13.3 Health reporting

```swift
public protocol ExportHealthReporting {
    func buildHealthReport(
        sessionID: UUID,
        parsedRecords: [ParsedSnapRecord]
    ) async throws -> ExportHealthReport
}
```

### 13.4 Metadata normalization

```swift
public protocol MetadataResolving {
    func resolveMetadata(
        for record: ParsedSnapRecord,
        mediaFileURL: URL?
    ) async throws -> ResolvedMetadata
}
```

### 13.5 Photos permission and library access

```swift
public protocol PhotosLibraryAuthorizing {
    func currentAuthorizationState() async -> PhotosAuthorizationState
    func requestFullAccess() async -> PhotosAuthorizationState
    func ensureMasterAlbum(named name: String) async throws -> PhotosAlbumReference
}
```

### 13.6 Library indexing and asset lookup

```swift
public protocol PhotosLibraryQuerying {
    func fetchCandidateAssets(
        near date: Date,
        mediaType: MediaType
    ) async throws -> [LibraryAssetReference]

    func fetchAssetDetails(
        localIdentifiers: [String]
    ) async throws -> [LibraryAssetReference]
}
```

### 13.7 Writing to Photos

```swift
public protocol PhotosAssetWriting {
    func saveAsset(
        from fileURL: URL,
        metadata: ResolvedMetadata,
        into album: PhotosAlbumReference
    ) async throws -> String
}
```

### 13.8 Duplicate analysis

```swift
public protocol DuplicateAnalyzing {
    func buildCandidates(
        for asset: ImportAsset
    ) async throws -> [DuplicateCandidate]

    func classifyDuplicate(
        importAsset: ImportAsset,
        libraryAsset: LibraryAssetReference
    ) async throws -> DuplicateCandidate
}
```

### 13.9 Duplicate review actions

```swift
public protocol DuplicateReviewActing {
    func recordDecision(
        candidateID: UUID,
        decision: DuplicateReviewDecision
    ) async throws

    func deleteReviewedLibraryAssets(
        candidateIDs: [UUID]
    ) async throws
}
```

### 13.10 Persistence stores

```swift
public protocol ImportSessionStore {
    func createSession(_ draft: ImportSessionDraft) async throws -> ImportSession
    func updateSession(_ session: ImportSession) async throws
    func fetchSession(id: UUID) async throws -> ImportSession?
    func fetchActiveSession() async throws -> ImportSession?
}

public protocol ParsedRecordStore {
    func save(_ records: [ParsedSnapRecord]) async throws
    func fetchRecords(sessionID: UUID) async throws -> [ParsedSnapRecord]
}

public protocol ImportAssetStore {
    func save(_ assets: [ImportAsset]) async throws
    func fetchAssets(sessionID: UUID) async throws -> [ImportAsset]
    func markImported(assetID: UUID, localIdentifier: String) async throws
    func markFailed(assetID: UUID, reason: ImportFailureReason) async throws
}

public protocol DuplicateCandidateStore {
    func save(_ candidates: [DuplicateCandidate]) async throws
    func fetchPending(sessionID: UUID) async throws -> [DuplicateCandidate]
}
```

### 13.11 Import orchestration

```swift
public protocol ImportCoordinating {
    func startScan(sourceURL: URL) async throws -> ImportSession
    func buildPlan(sessionID: UUID, mode: ImportMode) async throws
    func runImport(sessionID: UUID) async throws
    func resumeImport(sessionID: UUID) async throws
    func cancelImport(sessionID: UUID) async throws
}
```

### 13.12 Diagnostics

```swift
public protocol DiagnosticsReporting {
    func log(_ event: DiagnosticEvent) async
    func summary(for sessionID: UUID) async throws -> DiagnosticSummary
}
```

---

## 14. Import pipeline

This is the authoritative v1 pipeline.

### Phase 1: Source intake

- user picks ZIP or extracted folder
- app obtains security-scoped access
- app creates or resumes an `ImportSession`
- source is validated as an official Snapchat export structure

### Phase 2: Scan and validate

- list archive/folder entries
- locate relevant manifest/data files
- confirm expected export structure
- build initial discovery counts
- fail early if the structure is clearly unsupported

### Phase 3: Parse records

- parse the export metadata into `ParsedSnapRecord`
- resolve relative media paths
- detect missing file references
- capture raw metadata availability

### Phase 4: Health report

- compute:
  - total discovered
  - matched media
  - missing references
  - timestamp coverage
  - location coverage
  - unsupported items
- persist `ExportHealthReport`
- show the user the Export Health screen

### Phase 5: Build import plan

- apply import mode (Best Effort / Strict)
- normalize metadata
- create `ImportAsset` rows
- drop or flag items based on mode and validation status
- ensure master album target exists

### Phase 6: Candidate dedupe

- fetch narrowed candidate assets from the library
- classify exact vs suspected duplicates
- persist `DuplicateCandidate` rows
- adjust plan based on default dedupe handling

### Phase 7: Run import

- chunk import assets
- extract needed files lazily into working directory
- save to Photos with resolved metadata
- checkpoint after each batch
- persist success/failure state continually

### Phase 8: Review queue

- present duplicate candidates to the user
- allow skip / keep / review-later / delete-after-review actions
- no automatic destructive action

### Phase 9: Completion and cleanup

- build final `ImportSummary`
- show success screen
- optionally remove temporary working files
- keep session record for resume/history until cleaned up

---

## 15. Dedupe strategy

Use layered dedupe. Do not do expensive full-library comparisons blindly.

### 15.1 Classification model

- **Confirmed duplicate**
  - very strong evidence, such as exact or near-exact fingerprint match plus strong metadata alignment

- **Suspected duplicate**
  - plausible duplicate based on date proximity, dimensions, duration, type, size, and weak fingerprint alignment

### 15.2 Suggested stages

1. narrow candidate library assets using:
   - media type
   - creation date proximity window
   - dimension and duration hints

2. compute stronger fingerprints on narrowed sets

3. classify and score

4. persist candidate + reasoning

### 15.3 Duplicate review rules

- never auto-delete
- destructive actions require explicit user action
- the UI must show why something is being labeled as duplicate
- keep auditability:
  - confidence
  - reason code
  - decision state

---

## 16. Foreground/resume rules

The importer is **foreground-primary**.

This means:
- the UI assumes import is happening while the app is active
- if the app is interrupted, killed, or backgrounded for too long, progress is not lost
- the next launch should offer resume from the active session

Do not promise invisible background completion in v1.

Resumability requirements:
- persist phase changes
- persist completed imports
- persist extracted working state as needed
- persist failures with retry eligibility

---

## 17. Shell milestone

Cursor should treat this as the first real engineering milestone.

### Deliverables

- package structure exists
- SPM dependencies added
- design system tokens and components exist
- root app shell and navigation exist
- placeholder screens exist for all major screens
- DI container exists
- starter protocols exist
- GRDB database bootstrap and first migrations exist
- stub implementations exist where needed
- build compiles

### Placeholder screens required

- Welcome
- Permissions
- Import Source
- Export Health
- Import Options
- Import Progress
- Duplicate Review
- Import Success
- Settings
- Diagnostic Details

### Shell milestone should **not** yet attempt

- full parser implementation
- final PhotoKit write logic
- final dedupe engine
- final working extraction logic

The shell milestone is about structure, not shipping behavior.

---

## 18. Implementation milestone order

### Milestone 1: Shell + design system + persistence skeleton

Build:
- package structure
- design system
- screen shells
- protocol surface
- initial database schema
- DI composition

### Milestone 2: Source intake + export parsing + health report

Build:
- ZIP/folder intake
- security-scoped source handling
- export scan
- parser
- health report generation
- Export Health screen wiring

### Milestone 3: Import planning + metadata normalization

Build:
- mode selection
- metadata resolution
- plan generation
- import asset manifest persistence

### Milestone 4: PhotoKit write path + resumable import

Build:
- permission gating
- album creation
- asset save path
- chunked progress
- checkpoint/resume behavior

### Milestone 5: Library dedupe + review queue

Build:
- candidate narrowing
- scoring
- review screen
- user decision persistence
- explicit delete actions after review

### Milestone 6: Completion, cleanup, diagnostics, hardening

Build:
- success summary
- cleanup controls
- diagnostics
- edge-case handling
- QA hardening

---

## 19. Implementation guardrails for Cursor

Cursor should **not**:

- invent new modules unless justified
- collapse all code into the app target
- put parsing logic in SwiftUI views
- put PhotoKit calls throughout the codebase
- hard-code colors or typography in feature screens
- use a single giant view model for the whole app
- auto-delete duplicates
- silently ignore permission edge cases
- make backend assumptions

Cursor should:

- prefer clear boring names
- isolate frameworks behind protocols
- keep view models thin
- persist progress often
- keep the code reusable for a future Mac target
- make state explicit

---

## 20. Recommended starter file tree by package

This is intentionally concrete so Cursor can scaffold with less ambiguity.

```text
Packages/
├── DomainModels/
│   └── Sources/DomainModels/
│       ├── Models/
│       │   ├── ImportSession.swift
│       │   ├── ParsedSnapRecord.swift
│       │   ├── ImportAsset.swift
│       │   ├── DuplicateCandidate.swift
│       │   ├── ExportHealthReport.swift
│       │   └── ImportSummary.swift
│       ├── Enums/
│       │   ├── ImportMode.swift
│       │   ├── ImportPhase.swift
│       │   ├── MetadataConfidence.swift
│       │   ├── DuplicateConfidence.swift
│       │   ├── ImportFailureReason.swift
│       │   └── PermissionsState.swift
│       └── Support/
│           ├── PhotosAlbumReference.swift
│           ├── ResolvedMetadata.swift
│           └── DiagnosticEvent.swift
├── DesignSystem/
│   └── Sources/DesignSystem/
│       ├── Tokens/
│       │   ├── AppColor.swift
│       │   ├── AppText.swift
│       │   ├── AppSpacing.swift
│       │   └── AppRadius.swift
│       ├── Components/
│       │   ├── Buttons/
│       │   ├── Cards/
│       │   ├── Rows/
│       │   ├── Badges/
│       │   └── States/
│       └── Layout/
│           ├── ScreenHeader.swift
│           └── BottomActionBar.swift
├── Persistence/
│   └── Sources/Persistence/
│       ├── Database/
│       │   ├── AppDatabase.swift
│       │   ├── Migrations.swift
│       │   └── Tables.swift
│       ├── Stores/
│       │   ├── GRDBImportSessionStore.swift
│       │   ├── GRDBParsedRecordStore.swift
│       │   ├── GRDBImportAssetStore.swift
│       │   └── GRDBDuplicateCandidateStore.swift
│       └── Adapters/
│           └── RecordMappers.swift
├── ZipAccess/
│   └── Sources/ZipAccess/
│       ├── ImportSourceHandle.swift
│       ├── SecurityScopedAccess.swift
│       ├── ZIPImportSourceAccessor.swift
│       └── FolderImportSourceAccessor.swift
├── PhotosAccess/
│   └── Sources/PhotosAccess/
│       ├── Authorization/
│       │   ├── PhotoLibraryAuthorizer.swift
│       │   └── AuthorizationMapper.swift
│       ├── Library/
│       │   ├── PhotoLibraryQueryService.swift
│       │   ├── AlbumService.swift
│       │   └── PhotoLibraryDeletionService.swift
│       └── Write/
│           └── PhotoAssetWriter.swift
├── ImportEngine/
│   └── Sources/ImportEngine/
│       ├── Coordinator/
│       │   └── ImportCoordinator.swift
│       ├── Parsing/
│       │   ├── SnapchatExportScanner.swift
│       │   ├── SnapchatExportParser.swift
│       │   └── ExportStructureValidator.swift
│       ├── Metadata/
│       │   └── MetadataResolver.swift
│       ├── Planning/
│       │   ├── HealthReportBuilder.swift
│       │   ├── ImportPlanner.swift
│       │   └── ImportBatchBuilder.swift
│       ├── Execution/
│       │   ├── ImportExecutor.swift
│       │   ├── ResumeEngine.swift
│       │   └── WorkingDirectoryManager.swift
│       └── Support/
│           └── ImportProgressEmitter.swift
├── DedupeEngine/
│   └── Sources/DedupeEngine/
│       ├── CandidateNarrower.swift
│       ├── AssetFingerprinting.swift
│       ├── DuplicateClassifier.swift
│       └── DuplicateReasonBuilder.swift
├── Diagnostics/
│   └── Sources/Diagnostics/
│       ├── Logger/
│       │   └── DiagnosticsLogger.swift
│       ├── Summaries/
│       │   ├── SessionSummaryBuilder.swift
│       │   └── FailureSummaryBuilder.swift
│       └── Export/
│           └── DiagnosticBundleBuilder.swift
└── Feature*/
```

---

## 21. JSON output shape for Cursor understanding checkpoint

Before Cursor writes production code, require it to emit a structured understanding artifact.

Ask Cursor to create something like:

```json
{
  "project_name": "Snapchat Memories Import Utility",
  "core_promise": "Import official Snapchat Memories into Apple Photos accurately, privately, and safely.",
  "locked_decisions": {
    "platform": "iPhone-first",
    "photos_access": "full readWrite required",
    "input_scope": ["official export zip", "official extracted folder"],
    "processing": "on-device only",
    "import_mode_default": "best_effort",
    "strict_mode": true,
    "dedupe_scope": "full on-device library",
    "duplicate_deletion": "review_only",
    "import_model": "foreground_primary_resumable",
    "album_strategy": "one_master_album_v1",
    "zip_strategy": "stream_from_source_no_full_copy",
    "scale_target": "20GB design target"
  },
  "modules": [
    {
      "name": "DomainModels",
      "responsibilities": []
    },
    {
      "name": "DesignSystem",
      "responsibilities": []
    }
  ],
  "screens": [
    "WelcomeScreen",
    "PermissionsScreen",
    "ImportSourceScreen",
    "ExportHealthScreen",
    "ImportOptionsScreen",
    "ImportProgressScreen",
    "DuplicateReviewScreen",
    "ImportSuccessScreen",
    "SettingsScreen"
  ],
  "open_questions": [],
  "risks": [],
  "assumptions": []
}
```

Open questions should ideally be empty. If Cursor introduces new ones, review them manually before allowing implementation to proceed.

---

## 22. Prompt for the understanding checkpoint

Use this prompt in Cursor **before** asking it to build.

```text
Read docs/cursor_repo_brief.md as the authoritative architecture and product brief for this repo.

Do not start implementing the app yet.

First, produce two artifacts:

1. A Markdown file at docs/cursor_understanding.md
2. A JSON file at docs/cursor_understanding.json

Your job is to restate the project in your own words so we can verify alignment before coding.

Requirements:
- treat docs/cursor_repo_brief.md as the source of truth
- list all locked decisions explicitly
- restate the app’s core promise and non-goals
- restate the package/module structure and dependency boundaries
- restate the design system direction and screen inventory
- identify any assumptions you are making
- identify any risks or implementation hot spots
- identify any ambiguities or open questions only if they are truly blocking
- do not invent product scope beyond the brief
- do not write production code yet
- do not create extra architecture not justified by the brief

In the Markdown artifact, include:
- executive summary
- locked decisions
- module map
- screen map
- key risks
- implementation plan summary

In the JSON artifact, include:
- project_name
- core_promise
- locked_decisions
- non_goals
- modules
- screens
- assumptions
- risks
- open_questions

Stop after generating those two files.
```

---

## 23. Prompt for the shell milestone

Only use this after reviewing Cursor’s understanding output and resolving any real gaps.

```text
Read docs/cursor_repo_brief.md and docs/cursor_understanding.md.
Treat docs/cursor_repo_brief.md as the source of truth if there is any conflict.

Now implement the shell milestone only.

Scope:
- set up the app and package structure
- add Swift Package Manager dependencies for GRDB and ZIPFoundation
- scaffold internal modules/packages
- create the design system tokens and shared components
- create placeholder screens for all major flows
- create the root navigation shell
- create the dependency container / app composition root
- scaffold the starter protocols from the repo brief
- set up GRDB database bootstrap + initial migrations
- create stub service implementations where needed so the app compiles
- keep views thin
- do not implement the full import parser or final PhotoKit write path yet
- do not collapse everything into the app target
- do not invent a backend
- do not introduce flashy custom UI

Deliverables:
- compiling app shell
- package structure in place
- placeholder screens wired together
- starter protocols/types in place
- database initialization wired
- no broken references
- code comments only where useful, not excessive

At the end, create docs/shell_milestone_summary.md describing:
- what was created
- what remains stubbed
- any deviations from the repo brief
- any real blockers
```

---

## 24. Prompt for post-shell parser/import implementation

Use this only after the shell milestone is in good shape.

```text
Read docs/cursor_repo_brief.md and docs/shell_milestone_summary.md.
Continue from the existing architecture. Do not re-architect unless truly necessary.

Implement the next milestone:
Source intake + export parsing + export health reporting.

Scope:
- security-scoped source selection support for ZIP and extracted folder imports
- source validation for official Snapchat export structure
- archive/folder scanning
- parser for the required export metadata
- ParsedSnapRecord creation
- ExportHealthReport generation
- persistence of scan + parse results into GRDB
- wiring of ExportHealthScreen to real data
- robust error states for unsupported or incomplete exports

Requirements:
- do not implement final import-to-Photos yet
- do not implement duplicate deletion yet
- persist state so this work is resumable
- keep framework integration isolated to the intended packages
- update docs/parser_milestone_summary.md at the end

At the end, produce:
- docs/parser_milestone_summary.md
- docs/parser_known_limits.md
```

---

## 25. Review checklist before allowing Cursor to build further

Use this checklist after each milestone.

### Architecture
- are module boundaries still intact?
- did Cursor keep PhotoKit isolated?
- did Cursor keep GRDB isolated?
- did Cursor avoid putting logic in views?

### Product alignment
- does the UI still feel like a private utility?
- are locked decisions being respected?
- did Cursor quietly expand scope?

### State management
- are session and import states persisted?
- is resumability still a first-class concern?

### Code quality
- are names boring and clear?
- are protocols and implementations separated sensibly?
- are there giant god objects emerging?

### Design consistency
- are all screens using shared tokens/components?
- did Cursor hard-code visual styling in feature screens?

---

## 26. Things that require human review before merge

The following should not be accepted blindly from Cursor:

- permission handling UX copy
- dedupe confidence thresholds
- destructive action copy
- unsupported export edge-case behavior
- migration changes after initial schema
- any attempt to widen scope beyond the brief

---

## 27. Final directive to future contributors

If a future implementation decision conflicts with this document, update this document first or explicitly document the deviation in a milestone summary.

Do not let the codebase become the source of truth by accident.  
The architecture brief should remain the intentional source of truth during v1 buildout.
