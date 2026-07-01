# 📋 Backlog: TrashScan Lightweight MVP

## Phase 1: Foundation (COMPLETED)
- [x] Update `pubspec.yaml` with latest stable dependencies.
- [x] Scaffold project folder structure.
- [x] Create core domain models (`WasteCategory`, `ScanStatus`, `ScanResult`).
- [x] Implement lightweight purple & glass design system (`AppColors`, `AppTextStyles`).

## Phase 2: Camera & Permission
- [ ] Implement `PermissionProvider` for camera access tracking.
- [ ] Create `PermissionScreen` with denied-state handling.
- [ ] Initialize `CameraController` in `CameraService`.
- [ ] Build `CameraScreen` with fullscreen live preview.

## Phase 3: Realtime Simulation Logic
- [ ] Implement `MockClassifierService` for local simulation.
- [ ] Create `ScanProvider` for automatic periodic loop.
- [ ] Handle lifecycle events (pause on background, resume on foreground).
- [ ] Implement throttling/skipping logic for overlapping scan ticks.

## Phase 4: UI Overlay & Controls
- [ ] Build `ResultOverlay` glass panel.
- [ ] Implement `StatusPill` indicator.
- [ ] Build animated `ConfidenceBar`.
- [ ] Add Pause/Resume manual controls.

## Phase 5: Polish & Performance
- [ ] Optimize widget rebuilds using `RepaintBoundary`.
- [ ] Final performance check (startup time, frame rate stability).
- [ ] Finalize walkthrough documentation.
