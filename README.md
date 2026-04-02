# SnapOut

**SnapOut** is an iPhone-first utility that imports **official Snapchat Memories exports** into **Apple Photos**—with dates and locations restored where possible, duplicate handling against your full library, and a single master album (**“Snapchat Memories”**). Everything runs **on your device**: no Snapchat login, no backend, no cloud processing, and no media leaves the phone.

- **Platform:** iOS **17.0**+ (iPhone)
- **Input:** Official Snapchat export as a **ZIP** or an **extracted export folder**
- **Stack:** SwiftUI, Swift Package Manager, GRDB, ZIPFoundation, PhotoKit

## Building

1. Open `SnapOut.xcodeproj` in Xcode 15+.
2. Select the **SnapOut** scheme and an iPhone simulator or device.
3. Build and run (**⌘R**).

The Xcode project is generated from `project.yml` ([XcodeGen](https://github.com/yonaskolb/XcodeGen)). Regenerate with:

```bash
xcodegen generate
```

(Only needed if you change `project.yml` or paths.)

## Repository layout

| Path | Purpose |
|------|---------|
| `SnapOut/` | App target — composition root, navigation, wiring |
| `Packages/` | Feature modules, domain, persistence, Photos/ZIP access, import engine, design system |
| `docs/` | Product and architecture checkpoints (`cursor_understanding.md`, handoff notes) |
| `reference/snapchat-json/` | **Local only** — drop personal export JSON here for parser work; **not committed** (see `.gitignore`) |

## Privacy & safety

- Full Photos **read/write** access is required for v1 (full-library deduplication and import).
- Duplicate **deletion** is never automatic; destructive actions are explicit and separate from import review.
- Do not commit real Snapchat exports. Use `reference/snapchat-json/` on your machine only.

## Documentation

Authoritative planning and constraints live in:

- `cursor_repo_brief.md`
- `docs/cursor_understanding.md`
- `snap_import_handoff.md`

## License

All rights reserved unless and until a license is added to this repository.
