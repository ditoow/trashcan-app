# Data Flow: Scan Detection Cycle

```
┌─────────────────┐    1. init     ┌──────────────────────┐
│  CameraScreen    │──────────────→│  scanProvider          │
│  (ConsumerWidget) │              │  (ScanNotifier)        │
│                   │              │                        │
│                   │              │  Timer.periodic(2s)    │
└────────┬──────────┘              └───────────┬────────────┘
         │                                      │
         │  2. watch(scanProvider)               │ 3. _performScan()
         │   re-render on state change           │
         ▼                                      ▼
┌─────────────────┐              ┌──────────────────────────┐
│  UI Widgets      │              │  MockClassifierService    │
│  - StatusPill    │◄────result───│  - Future.delayed(0.5-1.5s)
│  - ResultOverlay │              │  - random label + rect    │
│  - ConfidenceBar │              └──────────────────────────┘
│  - BoundingBox   │
└─────────────────┘
```

## Step by step

1. **App start** → `main.dart` → `ProviderScope` → `TrashScanApp` checks `permissionProvider`
2. If granted → `CameraScreen` initializes camera + creates `ScanNotifier`
3. `ScanNotifier.build()` → auto-calls `startScanning()` → `Timer.periodic` every 2s
4. Each tick → `_performScan()` → sets status to `loading` → calls `MockClassifierService.classify()`
5. Service returns `ScanResult` (random) → state updated → UI rebuilds reactively
6. Pause button → `stopScanning()` → timer cancelled → status `paused`
7. App background → `didChangeAppLifecycleState` → disposes camera + stops timer
8. App resume → reinitializes camera + restarts scan

## Changelog

- 2026-06-18: Initial analysis
