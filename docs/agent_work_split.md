
# SnapOut — Multi-Agent Implementation Work Split

**Generated from:** `cursor_repo_brief.md` (source of truth), `cursor_understanding.md`, `cursor_understanding.json`
**Purpose:** Define the agent-level work split so separate Cursor agents can build in parallel with minimal conflicts.

---

## 1. Executive Recommendation

Split the implementation across **6 agents** with a strict sequencing gate after the first.

Agent 1 (Shell Foundation) is the prerequisite for everything. It produces the Xcode project, all SPM packages, design system, protocols, domain models, database skeleton, placeholder screens, navigation, and DI container. Every downstream agent starts from this foundation.

After Agent 1 completes, Agents 2–4 can begin **in parallel** because they own non-overlapping packages. Agent 5 starts slightly later because it depends on outputs from Agents 3 and 4. Agent 6 is a cleanup/hardening pass that can overlap with the tail end of Agents 4 and 5.

The primary merge-conflict risk is the `App/` directory (composition root, navigation wiring). This is managed by having the shell agent fully wire all placeholder screens and navigation upfront. Subsequent agents modify only their owned feature package internals and add real DI registrations to the composition root in a coordinated order.

The parser agent (Agent 3) is partially blocked: ZipAccess and parser scaffolding can proceed now, but real parser internals and parser tests are blocked until sample Snapchat export data arrives.

---

## 2. Proposed Agent List

### Agent 1: Shell Foundation

**Mission:** Build the entire project skeleton so all other agents have a compiling, navigable, architecturally correct starting point.

**Owned packages/modules:**
- `App/` (entry point, DependencyContainer, RootNavigation, AppCoordinator, AppEnvironment)
- `Packages/DomainModels/` (all models, enums, support types)
- `Packages/AppCore/` (all service protocols)
- `Packages/DesignSystem/` (all tokens, all shared components)
- `Packages/Persistence/` (AppDatabase, Migrations, Tables, empty store stubs)
- `Packages/ZipAccess/` (package scaffold, ImportSourceHandle type, empty accessor stubs)
- `Packages/PhotosAccess/` (package scaffold, empty service stubs)
- `Packages/ImportEngine/` (package scaffold, empty coordinator/parser/executor stubs)
- `Packages/DedupeEngine/` (package scaffold, empty stubs)
- `Packages/Diagnostics/` (package scaffold, empty stubs)
- `Packages/SharedTestSupport/` (package scaffold)
- All `Packages/Feature*/` (placeholder screens with DesignSystem components)
- `SnapOut.xcodeproj` creation
- SPM dependency wiring (GRDB, ZIPFoundation)

**Primary files likely to change:** Everything — this agent creates the repo from zero.

**Allowed to touch:** All files.

**Should avoid:** Implementing real business logic. Every service should be a protocol stub or no-op implementation that compiles and returns placeholder data.

**Dependencies on other agents:** None. This goes first.

**Outputs/deliverables:**
- Compiling Xcode project
- All packages with correct dependency graph
- All protocols defined in AppCore
- All domain models defined in DomainModels
- GRDB schema + migrations + empty store shells
- DesignSystem tokens + all shared components
- All 10 placeholder screens wired into NavigationStack
- DI container with stub registrations
- `docs/shell_milestone_summary.md`

**Likely risks:**
- SPM package graph resolution issues
- Xcode project configuration complexity (signing, capabilities)
- Getting the dependency graph correct on first try

---

### Agent 2: Persistence & State

**Mission:** Turn all GRDB store stubs into working implementations. Deliver the full persistence layer that every other agent depends on.

**Owned packages/modules:**
- `Packages/Persistence/Sources/Persistence/Stores/` (all store implementations)
- `Packages/Persistence/Sources/Persistence/Adapters/` (record mappers)
- `Packages/Persistence/Sources/Persistence/Database/` (schema refinements if needed)
- `Packages/SharedTestSupport/` (persistence mocks and fixtures)

**Primary files likely to change:**
- `GRDBImportSessionStore.swift`
- `GRDBParsedRecordStore.swift`
- `GRDBImportAssetStore.swift`
- `GRDBDuplicateCandidateStore.swift`
- `RecordMappers.swift`
- `AppDatabase.swift` (minor refinements only)
- `Tables.swift` (index additions only)
- New files: `GRDBImportFailureStore.swift`, `GRDBDiagnosticEventStore.swift`, `GRDBAppSettingsStore.swift`
- `SharedTestSupport/` mock store implementations

**Allowed to touch:**
- `Packages/Persistence/`
- `Packages/SharedTestSupport/`
- `Packages/AppCore/` — only if a store protocol needs a method addition (requires principal engineer approval)

**Should avoid:**
- `App/` directory
- All Feature packages
- ZipAccess, PhotosAccess, ImportEngine, DedupeEngine, Diagnostics
- DesignSystem

**Dependencies on other agents:** Agent 1 (shell must be complete).

**Outputs/deliverables:**
- All store protocols fully implemented with real GRDB queries
- Checkpoint read/write support
- Batch insert/update support for large record sets
- Index optimizations per the schema spec
- Mock store implementations in SharedTestSupport
- Persistence unit tests

**Likely risks:**
- GRDB API surface learning curve
- Migration versioning if schema needs late adjustments
- Performance on large record sets (needs profiling during hardening)

---

### Agent 3: Source Intake & Parser

**Mission:** Build the source acquisition pipeline (ZIP and folder) and the export parser. Deliver everything from "user picks a file" through "health report is displayed."

**Owned packages/modules:**
- `Packages/ZipAccess/Sources/ZipAccess/` (all files)
- `Packages/ImportEngine/Sources/ImportEngine/Parsing/` (all parser files)
- `Packages/ImportEngine/Sources/ImportEngine/Metadata/` (MetadataResolver)
- `Packages/ImportEngine/Sources/ImportEngine/Planning/HealthReportBuilder.swift`
- `Packages/FeatureImportSource/` (wire to real source picker)
- `Packages/FeatureExportHealth/` (wire to real health data)

**Primary files likely to change:**
- `ZIPImportSourceAccessor.swift`
- `FolderImportSourceAccessor.swift`
- `SecurityScopedAccess.swift`
- `ImportSourceHandle.swift`
- `SnapchatExportScanner.swift`
- `SnapchatExportParser.swift`
- `ExportStructureValidator.swift`
- `MetadataResolver.swift`
- `HealthReportBuilder.swift`
- FeatureImportSource view model and screen
- FeatureExportHealth view model and screen

**Allowed to touch:**
- `Packages/ZipAccess/`
- `Packages/ImportEngine/Sources/ImportEngine/Parsing/`
- `Packages/ImportEngine/Sources/ImportEngine/Metadata/`
- `Packages/ImportEngine/Sources/ImportEngine/Planning/HealthReportBuilder.swift`
- `Packages/FeatureImportSource/`
- `Packages/FeatureExportHealth/`
- `App/DependencyContainer.swift` — only to register real ZipAccess and parser implementations (coordinate with principal engineer)

**Should avoid:**
- `Packages/ImportEngine/Sources/ImportEngine/Execution/` (Agent 4's territory)
- `Packages/ImportEngine/Sources/ImportEngine/Planning/ImportPlanner.swift` (Agent 4)
- `Packages/ImportEngine/Sources/ImportEngine/Planning/ImportBatchBuilder.swift` (Agent 4)
- `Packages/ImportEngine/Sources/ImportEngine/Coordinator/ImportCoordinator.swift` (shared — coordinate)
- `Packages/PhotosAccess/`
- `Packages/DedupeEngine/`
- `Packages/Persistence/` (use stores via protocol, don't modify them)

**Dependencies on other agents:**
- Agent 1 (shell)
- Agent 2 (persistence stores must be functional for writing parsed records)
- Sample Snapchat export data (blocks real parser internals and parser tests)

**Outputs/deliverables:**
- Working ZIP and folder source access with security-scoped URL lifecycle
- Security-scoped bookmark persistence into session records
- Export structure validation
- Manifest discovery and record parsing (stub internals until sample data)
- Metadata resolution with confidence scoring
- Health report generation
- FeatureImportSource wired to real document picker
- FeatureExportHealth wired to real scan data
- `docs/parser_milestone_summary.md`
- `docs/parser_known_limits.md`

**Likely risks:**
- Blocked on sample data for parser internals
- Security-scoped URL edge cases (bookmark staleness, access revocation)
- ZIPFoundation memory usage on large archives

---

### Agent 4: Photos & Import Execution

**Mission:** Build the PhotoKit integration layer and the import execution pipeline. Deliver everything from "import plan is built" through "assets are saved to Photos with checkpointing."

**Owned packages/modules:**
- `Packages/PhotosAccess/Sources/PhotosAccess/` (all files)
- `Packages/ImportEngine/Sources/ImportEngine/Planning/ImportPlanner.swift`
- `Packages/ImportEngine/Sources/ImportEngine/Planning/ImportBatchBuilder.swift`
- `Packages/ImportEngine/Sources/ImportEngine/Execution/` (all files)
- `Packages/ImportEngine/Sources/ImportEngine/Support/ImportProgressEmitter.swift`
- `Packages/FeaturePermissions/` (wire to real PhotoKit auth)
- `Packages/FeatureImportOptions/` (wire to real plan data)
- `Packages/FeatureImportProgress/` (wire to real import progress)

**Primary files likely to change:**
- `PhotoLibraryAuthorizer.swift`
- `AuthorizationMapper.swift`
- `PhotoLibraryQueryService.swift`
- `AlbumService.swift`
- `PhotoAssetWriter.swift`
- `PhotoLibraryDeletionService.swift`
- `ImportPlanner.swift`
- `ImportBatchBuilder.swift`
- `ImportExecutor.swift`
- `ResumeEngine.swift`
- `WorkingDirectoryManager.swift`
- `ImportProgressEmitter.swift`
- FeaturePermissions view model and screen
- FeatureImportOptions view model and screen
- FeatureImportProgress view model and screen

**Allowed to touch:**
- `Packages/PhotosAccess/`
- `Packages/ImportEngine/Sources/ImportEngine/Planning/ImportPlanner.swift`
- `Packages/ImportEngine/Sources/ImportEngine/Planning/ImportBatchBuilder.swift`
- `Packages/ImportEngine/Sources/ImportEngine/Execution/`
- `Packages/ImportEngine/Sources/ImportEngine/Support/`
- `Packages/FeaturePermissions/`
- `Packages/FeatureImportOptions/`
- `Packages/FeatureImportProgress/`
- `App/DependencyContainer.swift` — only to register PhotosAccess and execution implementations (coordinate)

**Should avoid:**
- `Packages/ImportEngine/Sources/ImportEngine/Parsing/` (Agent 3)
- `Packages/ImportEngine/Sources/ImportEngine/Metadata/` (Agent 3)
- `Packages/ZipAccess/` (Agent 3)
- `Packages/DedupeEngine/` (Agent 5)
- `Packages/Persistence/` (use via protocols)

**Dependencies on other agents:**
- Agent 1 (shell)
- Agent 2 (persistence stores for checkpointing, asset state updates)
- Agent 3 is NOT a hard dependency — import execution works against `ImportAsset` rows already in the database. The two can build in parallel against the protocol surface.

**Outputs/deliverables:**
- Full PhotoKit authorization flow (request, block limited, settings recovery)
- Master album "Snapchat Memories" creation and management
- Asset save path with metadata application
- Chunked batch import execution
- Checkpoint/resume engine
- Working directory management and staged-file cleanup
- Import progress emission for UI
- FeaturePermissions wired to real auth
- FeatureImportOptions wired to real plan
- FeatureImportProgress wired to real execution
- `docs/import_execution_milestone_summary.md`

**Likely risks:**
- PhotoKit write reliability and error handling
- Crash-before-checkpoint reconciliation
- Memory pressure on large video assets
- Permission revocation mid-import

---

### Agent 5: Dedupe & Review

**Mission:** Build the duplicate detection engine and the review UI. Deliver the three-phase duplicate flow: pre-import decisioning, post-import review, and destructive delete review.

**Owned packages/modules:**
- `Packages/DedupeEngine/Sources/DedupeEngine/` (all files)
- `Packages/FeatureDuplicateReview/` (all files)

**Primary files likely to change:**
- `CandidateNarrower.swift`
- `AssetFingerprinting.swift`
- `DuplicateClassifier.swift`
- `DuplicateReasonBuilder.swift`
- FeatureDuplicateReview screens, view model, review cards

**Allowed to touch:**
- `Packages/DedupeEngine/`
- `Packages/FeatureDuplicateReview/`
- `App/DependencyContainer.swift` — only to register DedupeEngine implementations (coordinate)
- `Packages/AppCore/` — only if DuplicateAnalyzing or DuplicateReviewActing protocol needs adjustment (requires principal engineer approval)

**Should avoid:**
- `Packages/PhotosAccess/` (use via protocol for library queries and deletion)
- `Packages/Persistence/` (use via protocol for candidate storage)
- `Packages/ImportEngine/` (consume ImportAsset data via stores, don't modify engine)
- `Packages/ZipAccess/`
- Other feature packages

**Dependencies on other agents:**
- Agent 1 (shell)
- Agent 2 (persistence stores for candidate read/write)
- Agent 4 (PhotosAccess library query implementation must be available for candidate narrowing; PhotosAccess deletion implementation must be available for destructive delete review)

**Outputs/deliverables:**
- Coarse library index population (via PhotosAccess protocols)
- Candidate narrowing by media type, date, dimensions, duration
- Exact fingerprint verification (SHA-256 via CryptoKit)
- Perceptual hash computation for suspected duplicates
- Confidence scoring and reason code generation
- Three-phase review UI:
  1. Pre-import dedupe decisioning (keep/skip, non-destructive)
  2. Post-import review queue (keep/skip, non-destructive)
  3. Destructive delete review (separate confirmation, explicit only)
- Review card UI with side-by-side comparison, confidence badge, reason display
- `docs/dedupe_milestone_summary.md`

**Likely risks:**
- iCloud-backed assets not locally available during fingerprinting
- Large library indexing performance
- Perceptual hash quality and threshold tuning (requires human review)
- Confidence threshold calibration (requires human review)

---

### Agent 6: Completion, Diagnostics & Hardening

**Mission:** Build the completion/success flow, diagnostics system, settings screen, and harden the entire app for 20 GB-scale imports.

**Owned packages/modules:**
- `Packages/Diagnostics/Sources/Diagnostics/` (all files)
- `Packages/FeatureImportSuccess/` (all files)
- `Packages/FeatureSettings/` (all files, including DiagnosticDetailsScreen)
- `Packages/FeatureWelcome/` (resume session banner wiring)

**Primary files likely to change:**
- `DiagnosticsLogger.swift`
- `SessionSummaryBuilder.swift`
- `FailureSummaryBuilder.swift`
- `DiagnosticBundleBuilder.swift`
- FeatureImportSuccess screens and view model
- FeatureSettings screens and view model
- FeatureWelcome resume banner integration

**Allowed to touch:**
- `Packages/Diagnostics/`
- `Packages/FeatureImportSuccess/`
- `Packages/FeatureSettings/`
- `Packages/FeatureWelcome/` (resume banner only, not core welcome flow)
- `App/DependencyContainer.swift` — only to register Diagnostics implementations (coordinate)

**Should avoid:**
- `Packages/ImportEngine/` (except consuming its outputs via protocols)
- `Packages/DedupeEngine/`
- `Packages/PhotosAccess/`
- `Packages/ZipAccess/`
- `Packages/Persistence/` (use via protocols)

**Dependencies on other agents:**
- Agent 1 (shell)
- Agent 2 (persistence for session/failure queries)
- Agents 3, 4, 5 should be substantially complete so success/diagnostics screens can render real data
- Can start diagnostics infrastructure in parallel; success/settings wiring waits for engines

**Outputs/deliverables:**
- Structured local logging throughout the app
- Session summary generation from real data
- Failure summary with retry eligibility
- Diagnostic bundle export (redacted, privacy-safe)
- FeatureImportSuccess wired to real ImportSummary
- FeatureSettings wired to real privacy info, defaults, cleanup, diagnostics
- FeatureWelcome resume banner wired to session detection
- Temp file cleanup controls
- Edge-case hardening documentation
- `docs/hardening_milestone_summary.md`

**Likely risks:**
- Diagnostics depends on real data flowing through the pipeline — hard to fully test until engines work
- 20 GB hardening requires real large-scale test data
- Edge-case matrix is large

---

## 3. Suggested Sequencing

```
Phase 0 ─── Agent 1: Shell Foundation ──────────────────────────── GATE
                │
Phase 1 ───────┼── Agent 2: Persistence & State  ─────────┐
                │                                           │
                ├── Agent 3: Source Intake & Parser ────────┤
                │   (ZipAccess now; parser when data ready) │
                │                                           │
                └── Agent 4: Photos & Import Execution ────┤
                                                            │
Phase 2 ────────────────────── Agent 5: Dedupe & Review ───┤
                               (starts after Agent 4       │
                                PhotosAccess is ready)     │
                                                            │
Phase 3 ────────────────────── Agent 6: Completion ────────┘
                               Diagnostics & Hardening
                               (overlaps with Phase 2 tail)
```

---

## 4. Parallelizable Work After the Shell Milestone

### Fully parallel (Phase 1):

| Agent | Work | Why safe |
|-------|------|----------|
| Agent 2: Persistence | All GRDB store implementations | Owns Persistence package exclusively. No overlap with other agents. |
| Agent 3: Source & Parser | ZipAccess implementation, parser scaffolding | Owns ZipAccess and ImportEngine/Parsing exclusively. |
| Agent 4: Photos & Import | PhotosAccess implementation, import planner/executor | Owns PhotosAccess and ImportEngine/Execution exclusively. |

### Partially parallel (Phase 2):

| Agent | Work | Dependency |
|-------|------|------------|
| Agent 5: Dedupe | DedupeEngine + review UI | Needs Agent 4's PhotosAccess for library reads. Can start DedupeEngine scaffolding and classification logic while waiting. |
| Agent 6: Completion | Diagnostics infra, success/settings scaffolding | Can start Diagnostics package immediately. Success/settings wiring waits for engine data. |

### Sequential constraints:

- Agent 1 must fully complete before any other agent starts
- Agent 5 needs Agent 4's `PhotosLibraryQuerying` implementation for real candidate narrowing
- Agent 5 needs Agent 4's `PhotoLibraryDeletionService` for destructive delete review
- Agent 3's real parser internals are blocked until sample export data is available
- Agent 6's success screen wiring needs Agents 3–5 substantially done
- `ImportCoordinator.swift` is a coordination point — see section 8

---

## 5. Package Ownership by Agent

| Package | Shell (A1) | Persistence (A2) | Source/Parser (A3) | Photos/Import (A4) | Dedupe/Review (A5) | Completion (A6) |
|---------|:----------:|:-----------------:|:------------------:|:-------------------:|:-------------------:|:---------------:|
| App/ | Creates | — | Registers | Registers | Registers | Registers |
| DomainModels | Creates | — | — | — | — | — |
| AppCore | Creates | May extend | May extend | May extend | May extend | — |
| DesignSystem | Creates | — | — | — | — | — |
| Persistence | Creates stubs | **Owns** | — | — | — | — |
| ZipAccess | Creates stubs | — | **Owns** | — | — | — |
| PhotosAccess | Creates stubs | — | — | **Owns** | — | — |
| ImportEngine | Creates stubs | — | Parsing/, Metadata/, HealthReport | Planning/, Execution/, Support/ | — | — |
| DedupeEngine | Creates stubs | — | — | — | **Owns** | — |
| Diagnostics | Creates stubs | — | — | — | — | **Owns** |
| FeatureWelcome | Creates placeholder | — | — | — | — | Resume banner |
| FeaturePermissions | Creates placeholder | — | — | **Owns** | — | — |
| FeatureImportSource | Creates placeholder | — | **Owns** | — | — | — |
| FeatureExportHealth | Creates placeholder | — | **Owns** | — | — | — |
| FeatureImportOptions | Creates placeholder | — | — | **Owns** | — | — |
| FeatureImportProgress | Creates placeholder | — | — | **Owns** | — | — |
| FeatureDuplicateReview | Creates placeholder | — | — | — | **Owns** | — |
| FeatureImportSuccess | Creates placeholder | — | — | — | — | **Owns** |
| FeatureSettings | Creates placeholder | — | — | — | — | **Owns** |
| SharedTestSupport | Creates scaffold | **Owns** mocks | — | — | — | — |

---

## 6. File/Path Ownership by Agent

### Agent 1: Shell Foundation
```
Everything (creates all files)
```

### Agent 2: Persistence & State
```
Packages/Persistence/Sources/Persistence/Stores/*
Packages/Persistence/Sources/Persistence/Adapters/*
Packages/Persistence/Sources/Persistence/Database/ (refinements only)
Packages/Persistence/Tests/
Packages/SharedTestSupport/Sources/ (mock stores)
```

### Agent 3: Source Intake & Parser
```
Packages/ZipAccess/Sources/ZipAccess/*
Packages/ZipAccess/Tests/
Packages/ImportEngine/Sources/ImportEngine/Parsing/*
Packages/ImportEngine/Sources/ImportEngine/Metadata/*
Packages/ImportEngine/Sources/ImportEngine/Planning/HealthReportBuilder.swift
Packages/FeatureImportSource/Sources/*
Packages/FeatureExportHealth/Sources/*
```

### Agent 4: Photos & Import Execution
```
Packages/PhotosAccess/Sources/PhotosAccess/*
Packages/PhotosAccess/Tests/
Packages/ImportEngine/Sources/ImportEngine/Planning/ImportPlanner.swift
Packages/ImportEngine/Sources/ImportEngine/Planning/ImportBatchBuilder.swift
Packages/ImportEngine/Sources/ImportEngine/Execution/*
Packages/ImportEngine/Sources/ImportEngine/Support/*
Packages/FeaturePermissions/Sources/*
Packages/FeatureImportOptions/Sources/*
Packages/FeatureImportProgress/Sources/*
```

### Agent 5: Dedupe & Review
```
Packages/DedupeEngine/Sources/DedupeEngine/*
Packages/DedupeEngine/Tests/
Packages/FeatureDuplicateReview/Sources/*
```

### Agent 6: Completion, Diagnostics & Hardening
```
Packages/Diagnostics/Sources/Diagnostics/*
Packages/Diagnostics/Tests/
Packages/FeatureImportSuccess/Sources/*
Packages/FeatureSettings/Sources/*
Packages/FeatureWelcome/Sources/* (resume banner only)
```

---

## 7. Shared Contracts That Must Be Stabilized Early

These are defined in the shell milestone and should be treated as frozen after Agent 1 completes. Any change requires principal engineer coordination.

### AppCore protocols (frozen after shell):
- `ImportSourceAccessing`
- `SnapchatExportParsing`
- `ExportHealthReporting`
- `MetadataResolving`
- `PhotosLibraryAuthorizing`
- `PhotosLibraryQuerying`
- `PhotosAssetWriting`
- `DuplicateAnalyzing`
- `DuplicateReviewActing`
- `ImportSessionStore`
- `ParsedRecordStore`
- `ImportAssetStore`
- `DuplicateCandidateStore`
- `ImportCoordinating`
- `DiagnosticsReporting`

### DomainModels types (frozen after shell):
- All model structs and enums listed in the repo brief
- Field additions are allowed only with principal engineer approval

### DesignSystem tokens and components (frozen after shell):
- Tokens: `AppColor`, `AppText`, `AppSpacing`, `AppRadius`
- Components: all shared buttons, cards, rows, badges, states, layout helpers
- Feature agents consume these; they do not modify them

### Database schema (frozen after shell):
- All 8 tables and their columns
- Index additions are allowed via Agent 2
- Column additions require principal engineer approval and a new migration

---

## 8. Expected Handoff Points Between Agents

### Agent 1 → All agents
**Handoff:** Compiling project with all stubs. `docs/shell_milestone_summary.md` documents what's stubbed vs real.

### Agent 2 → Agents 3, 4, 5, 6
**Handoff:** Working persistence stores. Agents can now read/write real data through store protocols. Mock stores available in SharedTestSupport for unit testing.

### Agent 3 → Agent 4 (soft)
**Handoff:** Parsed records and health report exist in the database. Agent 4's import planner reads `ParsedSnapRecord` and `ImportAsset` rows to build the execution plan. However, Agent 4 can build and test the planner with mock data before Agent 3's parser is complete.

### Agent 3 → Agent 5 (soft)
**Handoff:** `ImportAsset` rows with content hashes and metadata exist in the database. Agent 5's dedupe engine compares these against library candidates.

### Agent 4 → Agent 5 (hard)
**Handoff:** Agent 5 needs Agent 4's `PhotosLibraryQuerying` implementation to fetch real library asset candidates. Agent 5 also needs `PhotoLibraryDeletionService` for destructive delete review.

### Agent 4 → Agent 6
**Handoff:** Import execution produces session state and failure records. Agent 6's success screen and diagnostics consume these.

### ImportCoordinator.swift — shared coordination point
This file orchestrates the full pipeline and is touched by Agents 3 and 4. Recommended approach:
- Agent 1 creates the stub coordinator with all phase methods
- Agent 3 implements the scan/parse/health phases
- Agent 4 implements the plan/execute/resume phases
- The principal engineer merges these into the coordinator if conflicts arise
- Alternative: split coordinator into `ScanCoordinator` (Agent 3) and `ExecutionCoordinator` (Agent 4) if cleaner

---

## 9. Merge-Conflict Risk Areas

### High risk

| File/area | Why | Mitigation |
|-----------|-----|------------|
| `App/DependencyContainer.swift` | Every agent registers real implementations here | Agents add registrations in a coordinated order. Principal engineer reviews all DI changes. |
| `ImportEngine/Coordinator/ImportCoordinator.swift` | Agents 3 and 4 both implement phases | Split into scan-phase and execution-phase coordinators, or principal engineer merges. |
| `App/RootNavigation.swift` | If agents change navigation structure | Shell wires all routes. Agents only change their feature package internals, not the navigation host. |

### Medium risk

| File/area | Why | Mitigation |
|-----------|-----|------------|
| `AppCore/` protocol files | Agents may need method additions | Freeze after shell. Changes require principal engineer approval. |
| `DomainModels/` model files | Agents may discover missing fields | Freeze after shell. Changes require principal engineer approval and a migration. |

### Low risk

| File/area | Why |
|-----------|-----|
| All infrastructure packages (Persistence, ZipAccess, PhotosAccess, DedupeEngine, Diagnostics) | Exclusive single-agent ownership. |
| All feature packages | Exclusive single-agent ownership after shell. |
| DesignSystem | Frozen after shell. Feature agents consume only. |

---

## 10. Recommended Review Order Before Merge

After each agent completes, review in this order:

1. **Agent 1 (Shell)** — Review before anything else starts. Check: all packages exist, dependency graph correct, protocols match brief, design system matches spec, database schema matches brief, all screens compile.

2. **Agent 2 (Persistence)** — Review next. Check: all stores implement their full protocol surface, queries are correct, batch operations work, mock stores exist.

3. **Agents 3 and 4 (Source/Parser and Photos/Import)** — Can be reviewed in either order since they don't overlap. Check: framework isolation respected, protocols consumed correctly, DI registrations correct, feature screens use DesignSystem.

4. **Agent 5 (Dedupe)** — Review after Agents 3 and 4. Check: three-phase duplicate flow is correctly separated, delete review is separate from keep/skip, confidence thresholds flagged for human review, library_asset_cache treated as stale-able cache.

5. **Agent 6 (Completion)** — Review last. Check: success screen uses real data, diagnostics are redacted, cleanup works, resume banner works, no scope expansion.

### Per-agent review checklist:
- Are module boundaries intact?
- Is PhotoKit only in PhotosAccess?
- Is GRDB only in Persistence?
- Are views using DesignSystem tokens, not hardcoded styles?
- Is AppCore still thin?
- Are there any god objects forming?
- Did the agent quietly expand scope?

---

## 11. Suggested Milestone Mapping

| Milestone | Contributing agents |
|-----------|-------------------|
| M1: Shell + design system + persistence skeleton | Agent 1 |
| M2: Source intake + export parsing + health report | Agent 2 (stores), Agent 3 (ZipAccess, parser, health) |
| M3: Import planning + metadata normalization | Agent 3 (metadata), Agent 4 (planner) |
| M4: PhotoKit write path + resumable import | Agent 2 (stores), Agent 4 (PhotosAccess, execution, resume) |
| M5: Library dedupe + review queue | Agent 2 (stores), Agent 4 (library queries), Agent 5 (engine, review UI) |
| M6: Completion, cleanup, diagnostics, hardening | Agent 6 (diagnostics, success, settings, hardening) |

---

## 12. Questions and Risks

### Remaining risk: ImportCoordinator split

The `ImportCoordinator` is logically one entity but is built by two agents (scanning phases by Agent 3, execution phases by Agent 4). Options:

1. **Split the coordinator** into `ScanCoordinator` and `ExecutionCoordinator` during shell, with a top-level `ImportCoordinator` that delegates. This is cleaner for parallel work.
2. **Keep one coordinator** and have the principal engineer merge the two agents' contributions.

**Recommendation:** Option 1 — split during shell. It's a small structural change that eliminates the highest merge-conflict risk.

### Remaining risk: DI container coordination

Every agent after shell needs to register real implementations in `DependencyContainer.swift`. Without coordination, this file will conflict.

**Recommendation:** Each agent adds registrations in a clearly marked section with a comment header (e.g., `// MARK: - PhotosAccess registrations`). The principal engineer does a final merge pass to resolve any ordering issues.

### No new blocking questions

All blocking questions have been resolved. The only remaining open item (Q1: Snapchat export format) blocks Agent 3's parser internals, not the agent split or shell milestone.

---

## 13. Recommended Next Prompt After Agent Split Approval

Use this prompt to kick off **only** the shell/foundation workstream (Agent 1). Do not start other agents until the shell is reviewed and approved.

```text
Read these files as your authoritative context:

- docs/cursor_repo_brief.md (source of truth)
- docs/cursor_understanding.md
- docs/cursor_understanding.json
- docs/agent_work_split.md (your scope is Agent 1: Shell Foundation only)

Treat docs/cursor_repo_brief.md as the source of truth if there is any conflict.

Now implement the shell milestone only. You are Agent 1: Shell Foundation.

Scope:
- Create the SnapOut Xcode project (iOS 17.0, iPhone target)
- Add SPM dependencies: GRDB, ZIPFoundation
- Create all internal SPM packages under Packages/ with correct dependency graph:
  DomainModels, AppCore, DesignSystem, Persistence, ZipAccess, PhotosAccess,
  ImportEngine, DedupeEngine, Diagnostics, SharedTestSupport,
  FeatureWelcome, FeaturePermissions, FeatureImportSource, FeatureExportHealth,
  FeatureImportOptions, FeatureImportProgress, FeatureDuplicateReview,
  FeatureImportSuccess, FeatureSettings
- Implement all DomainModels types and enums from the repo brief
- Implement all AppCore service protocols from the repo brief (AppCore must remain thin — protocols only)
- Implement the DesignSystem: all tokens (AppColor, AppText, AppSpacing, AppRadius)
  and all shared components (buttons, cards, rows, badges, states, layout helpers)
  per the design spec: native iOS, calm, high-trust, SF Pro + SF Symbols,
  neutral system colors, restrained blue/indigo accent
- Create GRDB database bootstrap: AppDatabase, Migrations (all 8 tables), Tables
- Create stub store implementations in Persistence that compile but return empty/placeholder data
- Create the App composition root: DependencyContainer with stub registrations,
  AppEnvironment, RootNavigation with NavigationStack, AppCoordinator
- Create placeholder screens for all 10 screens using DesignSystem components,
  wired into the navigation stack
- Create stub service implementations in ZipAccess, PhotosAccess, ImportEngine,
  DedupeEngine, and Diagnostics so everything compiles
- Do NOT implement real business logic — every service is a stub or no-op
- Do NOT collapse everything into the App target
- Do NOT introduce flashy custom UI
- Do NOT invent new modules or expand scope

Deliverables:
- Compiling app shell
- All packages with correct dependency graph
- All protocols and domain models in place
- Database initialized with schema
- All placeholder screens navigable
- No broken references
- Code comments only where useful

At the end, create docs/shell_milestone_summary.md describing:
- what was created
- what remains stubbed
- any deviations from the repo brief
- any real blockers
- the file tree that was generated
```
