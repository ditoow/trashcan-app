# Architecture Overview

**Style:** Layered monolith (feature-first)

```
lib/
├── domain/models/          ← Pure data layer
├── services/               ← Business logic / external integrations
├── features/               ← Feature modules (screen + provider + widgets)
│   ├── camera/
│   │   ├── camera_screen.dart
│   │   ├── providers/
│   │   └── widgets/
│   └── permission/
│       ├── permission_screen.dart
│       └── permission_provider.dart
└── shared/                 ← Cross-cutting concerns
    ├── theme/
    └── widgets/
```

## Dependency direction

`features → services → domain/models` and `features → shared`
Services never import features. Shared never imports features or services.

## Deviation from stated pattern

The spec mentions "provider/riverpod" but the code uses Riverpod `NotifierProvider` exclusively — no plain `Provider` package. This is fine and intentional.

## Changelog

- 2026-06-18: Initial analysis
