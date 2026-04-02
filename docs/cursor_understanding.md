
# SnapOut — Cursor Understanding Checkpoint

**Generated from:** `cursor_repo_brief.md` (authoritative source of truth)
**Purpose:** Restate the project in Cursor's own words so the founder can verify alignment before any code is written.

---

## 1. Executive Summary

SnapOut is an iPhone-first, on-device utility that takes an official Snapchat Memories export (ZIP or extracted folder), parses its manifest and media references, restores date and location metadata where possible, deduplicates against the user's existing Apple Photos library, and imports the results into a single master album — all without any backend, cloud storage, or Snapchat login.

The product is not a social app, slideshow maker, general photo organizer, or cloud backup service. It is a focused, privacy-first import pipeline with a premium feel, engineered for correctness, resumability, and trust.

The app requires full Photos `.readWrite` access. Limited access is blocked because v1 performs full-library deduplication. The import pipeline is foreground-primary with durable checkpointing so interrupted sessions resume cleanly. Duplicate deletion is review-only — the app never auto-deletes anything.

The architecture is modular: a thin SwiftUI presentation layer sits atop protocol-defined service boundaries, with all framework integrations (PhotoKit, GRDB, ZIPFoundation) isolated behind dedicated packages. The core logic is designed to be reusable by a future Mac target.

---

## 2. Locked Decisions

These are constraints, not proposals. All implementation must respect them.

### Platform and Scope

| Decision | Value |
|---|---|
| Primary platform | iPhone-first |
| Minimum deployment target | iOS 17.0 |
| Future extensibility | Core logic reusable by a future Mac target |
| Android | Not in v1 |
| Live Snapchat sync | Not in v1 |
| Backend / cloud | None. On-device processing only. No account system. |

### Input and Permissions

| Decision | Value |
|---|---|
| Input source | Official Snapchat export only |
| Accepted forms | Official export ZIP or extracted official export folder |
| Photos access | Full `.readWrite` required |
| Limited Photos access | Blocked — not sufficient for v1 |
| Explanation | Full access is required for full-library dedupe and safe import |

### Import and Pipeline Behavior

| Decision | Value |
|---|---|
| Default import mode | Best Effort |
| Optional mode | Strict Mode |
| Processing strategy | Stream/process from picked source; never copy the full ZIP into sandbox first |
| Execution model | Foreground-primary |
| Recovery model | Resumable and idempotent |
| Album strategy | One master album in v1, named "Snapchat Memories" |
| Scale target | 20 GB as the design target |

### Dedupe Behavior

| Decision | Value |
|---|---|
| Dedupe scope | Full on-device photo library |
| Duplicate deletion in v1 | Review-only |
| Auto-delete | Never |
| Classification | Confirmed duplicates and suspected duplicates |
| Review interaction | Deliberate swipeable review, not gamified |

### Privacy and UX Stance

The app must repeatedly communicate: no Snapchat login required, no backend processing, no cloud storage, no media leaving the device, one clear utility purpose, explicit user review before any destructive action.

### Tech Stack

| Decision | Value |
|---|---|
| Package manager | Swift Package Manager |
| Database | GRDB (SQLite-backed) |
| ZIP handling | ZIPFoundation |
| UI | SwiftUI with @Observable view models (iOS 17+) |
| Apple frameworks | PhotoKit, UTI, Security-scoped resources, AVFoundation, ImageIO, CryptoKit, OSLog |

---

## 3. Non-Goals for v1

The following are explicitly out of scope:

- Slideshow generation
- Face recognition or people clustering
- Cross-platform sync
- iCloud service features
- Social sharing features
- Cloud backup
- Collaboration
- Automatic duplicate deletion
- Backend analytics on media or location data
- General "organize all my photos" product expansion
- Android support
- iPad-first custom UX
- Mac app shipping in v1
- Subscription packaging decisions

---

## 4. Module Map

The project uses SPM for internal modularization. Each package has a bounded responsibility and strict dependency direction.

### 4.1 App (host target / composition root)

**Owns:** App entry point, root navigation, dependency composition, environment wiring, feature assembly. The App target is responsible for concrete wiring — it imports infrastructure packages and connects their implementations to the protocols defined in AppCore.

**Does not own:** Parsing logic, database schema, PhotoKit calls, ZIP processing, dedupe logic.

### 4.2 DomainModels

**Owns:** Pure shared models, enums, value types, protocol-facing DTOs.

**Key types:** `ImportSession`, `ParsedSnapRecord`, `ImportAsset`, `DuplicateCandidate`, `LibraryAssetReference`, `ExportHealthReport`, `ImportSummary`, `ResolvedMetadata`, `DiagnosticEvent`.

**Note on `ImportSession`:** Must explicitly include security-scoped bookmark data (or equivalent source re-acquisition metadata) so the source can be re-opened on resume. The session model must also handle bookmark staleness: if the source has been moved, deleted, or the bookmark can no longer resolve, the session should surface this as a recoverable error prompting the user to re-select the export source.

**Key enums:** `ImportMode`, `ImportPhase`, `ImportSessionStatus`, `MetadataConfidence`, `DuplicateConfidence`, `DuplicateReasonCode`, `ImportFailureReason`, `CleanupState`, `PermissionsState`.

**Must not import:** SwiftUI, GRDB, PhotoKit, ZIPFoundation.

### 4.3 DesignSystem

**Owns:** Color tokens (`AppColor`), typography tokens (`AppText`), spacing/radius tokens (`AppSpacing`, `AppRadius`), shared UI components, empty/loading/error states, layout helpers.

**Key components:** `PrimaryButton`, `SecondaryButton`, `DestructiveButton`, `SectionCard`, `StatCard`, `HealthSummaryCard`, `ProgressCard`, `IssueCard`, `InfoRow`, `SettingsRow`, `StatusBadge`, `MetadataConfidenceBadge`, `PermissionExplainerView`, `EmptyStateView`, `ErrorStateView`, `LoadingStateView`, `ScreenHeader`, `BottomActionBar`.

**Visual direction:** Native iOS, calm, high-trust, utility-first. SF Pro + SF Symbols only. Neutral system colors with restrained blue/indigo accent. No loud gradients, no Snapchat-adjacent branding.

### 4.4 AppCore

**Owns:** Service protocol definitions, use case interfaces, and lightweight composition-facing abstractions.

**Purpose:** Gives feature packages protocol-based access to import orchestration, permissions state, export scanning, duplicate review, and diagnostic summaries without direct framework coupling.

**Must remain thin.** AppCore is a contracts/protocol surface, not a god module. It must not accumulate concrete logic or unnecessary coupling to every infrastructure package. The App target (composition root) owns the concrete wiring of protocol implementations to consumers — AppCore defines the contracts, App wires the implementations.

### 4.5 Persistence

**Owns:** All GRDB usage. Database initialization, migrations, session/record/asset/candidate/failure/diagnostics stores.

**Exposes:** Stores and repositories through protocols defined in AppCore.

**Tables:** `import_sessions`, `parsed_snap_records`, `import_assets`, `library_asset_cache`, `duplicate_candidates`, `import_failures`, `diagnostic_events`, `app_settings`.

**Note on `library_asset_cache`:** This table is a refreshable cache derived from PhotoKit, not canonical truth. It may become stale if the user's Photos library changes outside the app (e.g., iCloud sync, deletions, additions from other apps). The dedupe engine must treat it as best-effort and support cache refresh when needed.

### 4.6 ZipAccess

**Owns:** All ZIPFoundation usage. Security-scoped file access. ZIP/folder opening, entry enumeration, targeted extraction, temporary extraction management, source URL lifecycle.

**Knows nothing about:** PhotoKit.

### 4.7 PhotosAccess

**Owns:** All PhotoKit integration. Permission checks/prompts, album create/fetch, library reads for dedupe, asset import/save, duplicate review deletion, full-access enforcement.

**Is the only package touching PhotoKit directly.**

### 4.8 ImportEngine

**Owns:** Core import orchestration. Source scanning, export parsing coordination, validation/health report generation, metadata normalization, import planning, chunked import execution, resumability, phase transitions, completion summaries.

**This is the local backend of the app.** Depends on other packages through protocol interfaces.

### 4.9 DedupeEngine

**Owns:** Duplicate analysis. Candidate set building, import-vs-library comparison, exact match rules, suspected match rules, scoring, reasoning, review queue material output.

**Does not own:** Delete actions (those belong to PhotosAccess).

### 4.10 Diagnostics

**Owns:** Local logs, summaries, human-readable diagnostic material, redacted support bundles.

### 4.11 Feature Packages

Each feature package owns its SwiftUI screens, view models, feature-specific view state, domain-to-presentation mapping, and navigation hooks.

**Feature packages depend on:** DesignSystem, DomainModels, AppCore, relevant service protocols.

**Feature packages do not depend on:** GRDB, PhotoKit, ZIPFoundation directly.

**Feature packages:** FeatureWelcome, FeaturePermissions, FeatureImportSource, FeatureExportHealth, FeatureImportOptions, FeatureImportProgress, FeatureDuplicateReview, FeatureImportSuccess, FeatureSettings.

### 4.12 SharedTestSupport

**Owns:** Shared test fixtures, mocks, and helpers for unit/integration tests across packages.

---

## 5. Dependency Graph

```
App (composition root — owns all concrete wiring)
├── AppCore
├── Feature* (all feature packages)
├── DesignSystem
├── DomainModels
├── Persistence          (concrete, wired here)
├── ZipAccess            (concrete, wired here)
├── PhotosAccess         (concrete, wired here)
├── ImportEngine         (concrete, wired here)
├── DedupeEngine         (concrete, wired here)
└── Diagnostics          (concrete, wired here)

Feature*
├── AppCore              (protocols only)
├── DesignSystem
└── DomainModels

AppCore (thin — protocols and lightweight abstractions only)
└── DomainModels

ImportEngine
├── DomainModels
└── AppCore              (consumes protocols, receives implementations via DI)

DedupeEngine
├── DomainModels
└── AppCore              (consumes protocols, receives implementations via DI)

Persistence
├── DomainModels
└── GRDB (third-party)

ZipAccess
└── ZIPFoundation (third-party)

PhotosAccess
└── PhotoKit (Apple framework)
```

**Hard rules:**
- UI packages never reach into PhotoKit, GRDB, or ZIPFoundation
- DomainModels remains framework-light and reusable
- All framework-heavy integrations are isolated behind their package boundary
- AppCore must remain thin — protocols and lightweight abstractions only, no concrete infrastructure coupling
- The App target (composition root) is the only place that imports both AppCore protocols and infrastructure implementations to wire them together

---

## 6. Screen Map

| # | Screen | Purpose |
|---|--------|---------|
| 1 | WelcomeScreen | Explain app purpose, reinforce privacy promise, direct user to import flow. Check for resumable sessions. |
| 2 | PermissionsScreen | Explain why full Photos access is required. Block until full access is granted. Show settings recovery if denied. |
| 3 | ImportSourceScreen | Pick ZIP or extracted folder. Explain official export requirement. Acquire security-scoped access. Create session. |
| 4 | ExportHealthScreen | Show scan results: total found, matched media, timestamp/location coverage, missing refs, health score, warnings. |
| 5 | ImportOptionsScreen | Lock Best Effort vs Strict Mode. Confirm dedupe behavior. Confirm album destination. |
| 6 | ImportProgressScreen | Show phase, progress counts, reassure resumability, show current batch state. |
| 7 | DuplicateReviewScreen | Review suspected/confirmed duplicates. Keep, skip, review-later, or delete-after-review. Never auto-delete. |
| 8 | ImportSuccessScreen | Summarize results: imported, skipped, queued, failed. Offer open Photos. Offer cleanup. |
| 9 | SettingsScreen | Show privacy posture, import defaults, diagnostics export, cleanup working files. |
| 10 | DiagnosticDetailsScreen | (Implied by shell milestone) Detailed diagnostic/failure view if needed. |

---

## 7. Import Pipeline Summary

The import pipeline is a durable state machine with persisted transitions:

1. **Source intake** — User picks ZIP or folder. App acquires security-scoped access and persists a security-scoped bookmark (or equivalent source re-acquisition metadata) into the session record. Session created or resumed. Source validated as official Snapchat export.
2. **Scan and validate** — Enumerate entries. Locate manifests. Confirm structure. Build discovery counts. Fail early on unsupported input.
3. **Parse records** — Decode export metadata into `ParsedSnapRecord` rows. Resolve media paths. Detect missing references. Capture raw metadata availability.
4. **Health report** — Compute total discovered, matched media, missing refs, timestamp coverage, location coverage, unsupported items. Persist `ExportHealthReport`. Show Export Health screen.
5. **Build import plan** — Apply import mode. Normalize metadata. Create `ImportAsset` rows. Drop or flag items per mode and validation status. Ensure master album exists.
6. **Candidate dedupe** — Narrow library candidates by media type, date proximity, dimensions, duration. Classify exact vs suspected. Persist `DuplicateCandidate` rows. Adjust plan.
7. **Run import** — Chunk assets into batches. Extract lazily into working directory. Save to Photos with resolved metadata. Checkpoint after each batch. Persist success/failure.
8. **Review queue** — Present duplicate candidates. User chooses skip/keep/review-later/delete-after-review. No auto-delete.
9. **Completion and cleanup** — Build `ImportSummary`. Show success screen. Optionally remove temp files. Keep session record.

---

## 8. Dedupe Strategy Summary

Layered dedupe — never do expensive full-library comparisons blindly.

**Stage 1 — Narrow candidates** using media type, creation date proximity, dimension and duration hints.

**Stage 2 — Compute stronger fingerprints** only on the narrowed set.

**Stage 3 — Classify and score** as confirmed or suspected duplicate.

**Stage 4 — Persist** candidate with confidence, reason code, and decision state.

**Classification:**
- **Confirmed duplicate:** Very strong evidence (exact/near-exact fingerprint match + strong metadata alignment). Default action: skip import.
- **Suspected duplicate:** Plausible match based on date proximity, dimensions, duration, type, size, weak fingerprint. Default action: queue for review.

### Duplicate flow phases (must be kept distinct)

The duplicate workflow has three separate phases. They must not be collapsed into a single flow:

1. **Pre-import dedupe decisioning** — Before import execution, the engine classifies candidates and applies default actions (skip confirmed duplicates, queue suspected duplicates for review). The user may optionally review suspected duplicates before import begins. Keep/skip decisions are non-destructive and only affect whether an item is imported.

2. **Post-import review queue** — After import completes, the app surfaces any remaining unresolved suspected duplicates and the confirmed duplicates that were skipped. The user can review these and make keep/skip decisions. These decisions do not delete anything.

3. **Destructive delete review** — Deletion of existing library assets is a separate, explicit action. It is never bundled with keep/skip choices. Delete actions require their own confirmation step and are only available for items the user has explicitly chosen to remove. No auto-delete under any circumstances.

**Review rules:** Never auto-delete. Destructive actions require explicit, separate user action with confirmation. UI must show why something is labeled duplicate. Auditability: confidence, reason code, decision state.

---

## 9. Key Risks and Implementation Hot Spots

### 9.1 Unknown Snapchat export format

**Risk:** No sample export data is available yet. The manifest JSON structure, field names, folder hierarchy inside the ZIP, and media path conventions are unknown. The parser is the spine of the entire pipeline, and its concrete internals cannot be finalized without real input.

**What is NOT blocked:** The shell milestone, parser protocol interfaces, parser module scaffolding, and the overall pipeline architecture are all unblocked. These can be built now.

**What IS blocked:** Real parser implementation (manifest decoding, field mapping, path resolution) and parser unit tests require sample Snapchat export data. These are blocked until sample data is available.

**Mitigation:** The parser is behind protocol boundaries and structured as a pluggable resolver chain. When sample data arrives, the parser internals can be built without disturbing the rest of the architecture.

### 9.2 Security-scoped URL lifecycle

**Risk:** iOS security-scoped URLs must be carefully managed. Access must be started before reading and stopped when done. If the app is killed mid-session and relaunched, bookmark data must be used to re-acquire access. If the user moves or deletes the source file between sessions, the source becomes unrecoverable.

**Mitigation:** ZipAccess package isolates this concern. Session persistence includes source bookmark data. Resume flow must handle the case where source access cannot be re-established.

### 9.3 iCloud-backed library assets during dedupe

**Risk:** PHAssets in the user's library may have their original resource data stored in iCloud and not locally available. Requesting the data for fingerprinting may trigger downloads, be slow, or fail. This can cause the exact-match dedupe path to stall or produce incomplete results.

**Mitigation:** The dedupe engine should degrade gracefully: if exact verification cannot complete promptly, classify as suspected rather than confirmed. Allow deferred verification. Do not block the entire pipeline on a single asset download.

### 9.4 20 GB-scale import performance

**Risk:** Staging, hashing, and writing 20 GB of media on a phone is resource-intensive. Memory pressure, storage pressure, and long foreground sessions are all concerns.

**Mitigation:** Batched execution with bounded batch sizes, aggressive staged-file cleanup after each batch, dynamic batch sizing under memory pressure, and persistent checkpointing so long sessions survive interruption.

### 9.5 PhotoKit write reliability

**Risk:** PhotoKit change requests can fail for various reasons (permissions revoked, album issues, storage full, unexpected errors). The app crashes between a successful PhotoKit write and the local DB update would mean a "ghost" import that the resume engine cannot see.

**Mitigation:** Checkpoint imported asset local IDs immediately after PhotoKit confirms success. On resume, include a reconciliation step that inspects recently created assets before re-importing. Keep batch sizes small enough that the window for crash-before-checkpoint is narrow.

### 9.6 ZIPFoundation edge cases

**Risk:** ZIPFoundation is the right default for standard ZIP intake, but if Snapchat exports are sometimes password-protected or use ZIP features outside what ZIPFoundation handles, the ZIP layer would need to be swapped.

**Mitigation:** ZIP access is behind a protocol. The implementation can be replaced without disturbing the rest of the system.

### 9.7 Large photo library indexing time

**Risk:** A user with a very large Photos library (50K+ assets) will experience slow library indexing during the dedupe phase. Full-library fingerprinting is prohibitively expensive.

**Mitigation:** Use only coarse, cheap attributes (media type, date, dimensions, duration) for the library index. Only compute expensive fingerprints on the narrowed candidate set. Show explicit progress during indexing.

---

## 10. Assumptions

These are assumptions I am making that are not explicitly stated in the brief but seem reasonable. Flag any that are incorrect.

1. **App name is "SnapOut"** — The workspace is named SnapOut. The brief uses "SnapImportApp" as the Xcode project and target name. I will use "SnapOut" as the product name and adjust target names accordingly.

2. **iOS 17.0 minimum deployment target** — This was confirmed in prior conversation. It enables `@Observable`, `NavigationStack`, modern structured concurrency, and current PhotoKit APIs.

3. **Single Xcode project, not workspace** — The brief shows `SnapImportApp.xcodeproj` with local SPM packages inside `Packages/`. I assume a single-project setup with embedded local packages, not a multi-project workspace.

4. **Test targets live inside each package** — Each SPM package will have its own test target. `SharedTestSupport` provides shared fixtures and mocks.

5. **No CI/CD pipeline in v1** — The brief does not mention CI. I assume local development and manual testing only.

6. **"protocol-facing" dependencies means protocol-only, not concrete imports** — When the brief says ImportEngine depends on ZipAccess "protocol-facing," I interpret this as: ImportEngine depends on protocol definitions (likely in AppCore or DomainModels) and receives concrete implementations via dependency injection, not that ImportEngine imports the ZipAccess module directly.

7. **Diagnostics screen is a secondary detail view** — The shell milestone lists "Diagnostic Details" as a placeholder screen. I assume this is a detail/sub-screen accessible from Settings, not a primary flow screen.

8. **No localization in v1** — The brief does not mention localization. I assume English-only.

9. **Monorepo structure** — All packages live inside the same repository and Xcode project. No separate repos for individual packages.

---

## 11. Open Questions

These are questions that are not currently blocking architecture or shell milestone work, but will need answers before their respective implementation milestones.

| # | Question | Blocks | Status |
|---|----------|--------|--------|
| 1 | What is the actual Snapchat export manifest structure (JSON schema, file naming conventions, folder hierarchy)? | Milestone 2 (parser implementation) | Open — waiting for sample data. Shell milestone and parser interfaces are NOT blocked. |
| 2 | What is the master album name in Photos? | Milestone 4 (PhotoKit writes) | **Resolved — "Snapchat Memories"** |
| 3 | Where should service protocols live? | Milestone 1 (shell scaffold) | **Resolved — all service protocols centralized in AppCore. Infrastructure packages provide implementations. Feature packages depend on AppCore for their protocol surface.** |
| 4 | How should the resume flow surface in the UI? | Milestone 1 (navigation wiring) | **Resolved — conditional card/banner on the Welcome screen. Tapping navigates into the resume point. No separate top-level screen.** |

Q1 is the only remaining open question. It does not block the shell milestone or parser interface scaffolding — only the real parser implementation and parser tests.

---

## 12. Implementation Plan Summary

### Milestone 1: Shell + Design System + Persistence Skeleton

- Xcode project with SPM packages
- All packages scaffolded with correct dependency graph
- Design system tokens and shared components
- Placeholder screens for all 10 screens, wired into root navigation
- Starter protocol surface from the brief
- DI container / composition root
- GRDB bootstrap with initial migrations
- Stub service implementations so the app compiles
- No real import, parse, dedupe, or PhotoKit logic

### Milestone 2: Source Intake + Export Parsing + Health Report

- ZIP/folder intake with security-scoped access
- Source validation for official Snapchat export structure
- Manifest discovery and record parsing
- `ParsedSnapRecord` creation and persistence
- `ExportHealthReport` generation
- Export Health screen wired to real data
- Error states for unsupported/incomplete exports
- *Requires sample export data to finalize parser internals*

### Milestone 3: Import Planning + Metadata Normalization

- Import mode selection (Best Effort / Strict)
- Metadata resolution with confidence scoring
- Import plan generation with `ImportAsset` rows
- Persistence of plan state

### Milestone 4: PhotoKit Write Path + Resumable Import

- Permission gating (full access enforcement, limited access blocker)
- Master album creation
- Asset save path with resolved metadata
- Chunked batch execution
- Checkpoint/resume behavior
- Import Progress screen wired to real data

### Milestone 5: Library Dedupe + Review Queue

- Coarse library index build
- Candidate narrowing
- Exact and suspected duplicate classification
- Duplicate Review screen with user decision persistence
- Explicit delete actions after review

### Milestone 6: Completion, Cleanup, Diagnostics, Hardening

- Import success summary from real session data
- Cleanup controls for temp/working files
- Diagnostics logging and optional export
- Edge-case handling (storage pressure, permission revocation, crash recovery)
- QA hardening for 20 GB-class imports
