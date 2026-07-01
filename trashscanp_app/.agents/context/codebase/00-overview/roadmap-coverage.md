# Roadmap Coverage

Based on MVP spec (`docs/superpowers/specs/2026-06-08-trashscan-lightweight-mvp-design.md`).

## Implemented (M0–M3)

| Milestone | Status | Notes |
|---|---|---|
| M0: Project Foundation | ✅ Done | Folder structure, models, theme |
| M1: Camera & Permission | ✅ Done | Permission screen, camera live preview, lifecycle |
| M2: Scan Loop & Mock Logic | ✅ Done | Timer.periodic, throttling, MockClassifierService |
| M3: Result Overlay | ✅ Done | ResultOverlay, StatusPill, ConfidenceBar, bounding box |

## Not yet implemented (M4+)

| Milestone | Depends on |
|---|---|
| M4: Performance optimization (RepaintBoundary) | M3 done |
| Walkthrough guide feature | M4 done |
| Education feature (`features/education/`) | — (empty dir) |
| Real ML classifier integration | Future |
| Real API integration | Future |
| Test coverage beyond smoke test | — |

## Changelog

- 2026-06-18: Initial analysis
