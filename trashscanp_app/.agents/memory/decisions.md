# Decisions (ADR Log)

> Append-only. Read before proposing an approach that contradicts an earlier decision.
> If you do propose a change, add a new entry — never edit old ones.

## Changelog

- 2026-06-18: Initial entry — camera preview fix

## Format

```
## YYYY-MM-DD — Short decision title
**Context:** Why this decision was needed.
**Decision:** What was decided.
**Alternatives considered:** What else was considered and why rejected.
**Status:** Active | Superseded by [link]
```

---

## 2026-06-18 — Camera preview fullscreen tanpa stretch
**Context:** Camera preview tampil "gepeng" (stretch) di layar 9:16 karena aspek rasio kamera (4:3 atau 16:9) berbeda dengan layar. Layout cycle terjadi saat pake `FittedBox` + `CameraPreview` karena internal `AspectRatio` + `StackFit.expand` di `CameraPreview`.

**Decision:**
1. Gunakan `ResolutionPreset.high` (1280×720, 16:9) bukan `medium` (640×480, 4:3) — 16:9 di portrait = 9:16, hampir sama dengan layar iPhone
2. Susun preview camera dengan pola: `Positioned.fill > LayoutBuilder > ClipRect > Transform.scale > Center > CameraPreview`
   - `Center` kasih loose constraints → `CameraPreview` internal `AspectRatio` render di rasio benar
   - `Transform.scale` zoom visual untuk isi layar
   - `ClipRect` crop kelebihan
3. `FittedBox` + `CameraPreview` TIDAK boleh digabung — menyebabkan layout cycle

**Alternatives considered:**
- `FittedBox(fit: BoxFit.cover)` + `CameraPreview` — layout cycle (RenderBox assertion error)
- `controller.buildPreview()` langsung — stretch karena gak handle rotasi orientation
- `ResolutionPreset.medium` — terlalu banyak crop (31% dari sisi)
- `Center` + `CameraPreview` tanpa scale — letterbox, ga fullscreen

**Status:** Active
