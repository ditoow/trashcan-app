# Coding Rules

> Conventions an agent cannot reliably infer from code alone. Keep entries short
> and concrete — one real example beats a paragraph of description.

## Detected at setup time

- Stack: Flutter (Dart 3.11+, Riverpod, Cupertino)
- Lint/format configs: `analysis_options.yaml` (package:flutter_lints/flutter.yaml)
- Build: `flutter build`
- Test:  `flutter test`
- Lint:  `flutter analyze`

> Auto-detected — may be incomplete. Review and correct as needed.

## Language / framework versions

- Dart SDK ^3.11.4 — do not suggest syntax requiring Dart 4.0+
- Flutter stable channel (revision db50e20168db8fee486b9abf32fc912de3bc5b6a)
- State management: Riverpod ^3.3.1 (NotifierProvider + ConsumerWidget/ConsumerStatefulWidget)

## Naming conventions

- **Files:** `snake_case.dart` (e.g. `scan_provider.dart`, `glass_card.dart`)
- **Classes/Enums:** `PascalCase` (e.g. `MockClassifierService`, `WasteCategory`)
- **Variables/Functions:** `camelCase` (e.g. `_performScan()`, `_isProcessing`)
- **Private members:** prefix with `_` (e.g. `_timer`, `_classifier`)
- **Branches:** `feature/<slug>`, `fix/<slug>`

## Error handling

- Never crash the UI — catch errors in providers/services and propagate through state (see `ScanStatus.error`)
- Use `debugPrint` for logs, never `print`
- Avoid `try-catch` swallowing — log the error, update state, let UI handle gracefully

## Testing

- Framework: `flutter_test` (package: flutter_test)
- Test location: `test/` directory
- At minimum: widget smoke test + provider unit tests for each new feature
- Run `flutter test` before declaring done

## Dependencies

- Pin major versions with `^` (compatible upgrades allowed)
- Do NOT add: `provider` (use Riverpod), `http` or `dio` (no API yet), any ML framework (mock classifier only)
- New deps must be approved by user

---

## Workflow Rules (read before every task)

### Feature workflow — MANDATORY, auto-triggered
When the task involves a new endpoint / entity / behavior / module that does not
exist yet: follow `.agents/skills/feature-workflow/SKILL.md` before writing any
code. Do not wait for the user to invoke it explicitly.

Detection heuristic — ask internally:
- Does this add a new route, model, or domain concept?
- Does `.agents/context/codebase/` have no mention of this thing?
→ Both yes = new feature = feature-workflow required.

### Changelog — every file you modify
Append one line to the file's `## Changelog` section (newest on top):
`- YYYY-MM-DD: <what changed and why, brief>`
Never create a separate changelog file.

### Error-check — after every coding task
Run `.agents/skills/error-check/SKILL.md` before declaring done.
Never skip silently.

### Backlog — out-of-scope ideas
If you notice something worth doing but out of current scope, append to
`.agents/logs/fixes/LOG.md` under a `## Backlog` heading — don't act on it.

### Things agents commonly get wrong here

- _(add entries as they come up — the most valuable section)_
