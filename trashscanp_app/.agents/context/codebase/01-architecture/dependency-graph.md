# Dependency Graph (Internal)

```
main.dart
  ├── features/permission/permission_provider.dart  →  permission_handler
  ├── features/permission/permission_screen.dart     →  permission_provider, app_colors, app_text_styles
  ├── features/camera/camera_screen.dart             →  scan_provider, widgets/*, app_colors, glass_card
  │     └── scan_provider.dart                       →  MockClassifierService, models/*
  │           └── mock_classifier_service.dart        →  models/*
  └── shared/theme/*                                 →  (no internal deps)
```

## Riverpod provider graph

```
permissionProvider (NotifierProvider<PermissionNotifier, PermissionStatus>)
  └── watched by TrashScanApp (root → decides home screen)

scanProvider (NotifierProvider<ScanNotifier, ScanState>)
  └── watched by CameraScreen, StatusPill, ResultOverlay, ConfidenceBar, BoundingBox
```

No circular dependencies detected. Clean layered hierarchy.

## External package dependencies

- `flutter_riverpod` → state management
- `camera` → camera controller
- `permission_handler` → platform permissions
- `google_fonts` → typography
- `flutter_image_compress` → (installed, not yet used in code)
- `path_provider` → (installed, not yet used in code)

## Changelog

- 2026-06-18: Initial analysis
