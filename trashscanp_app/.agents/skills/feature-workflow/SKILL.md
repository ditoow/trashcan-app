---
name: feature-workflow
description: Mandatory workflow for any new feature, endpoint, entity, or behavior
  that does not exist yet in the codebase. Auto-triggered — never wait for user to
  invoke. Trigger on "buat fitur", "add feature", "implement X", "tambahin Y",
  "endpoint baru", "tambah entity", "butuh fungsi", "bisa ga ditambahin", or any
  request that adds something new.
metadata:
  domain: workflow
  triggers: feature baru, new feature, tambah fitur, implement, add feature, bikin
    fitur, endpoint baru, tambah entity, butuh fungsi untuk, bisa ga ditambahin,
    mau ada fitur, design doc, implementation plan
  role: process
  scope: documentation
  related-skills: error-check, flutter-add-integration-test, flutter-add-widget-preview, flutter-add-widget-test, flutter-apply-architecture-best-practices, flutter-build-responsive-layout, flutter-fix-layout-issues, flutter-implement-json-serialization, flutter-setup-declarative-routing, flutter-setup-localization, flutter-use-http-package
---

# Feature Workflow — Spec → Plan → Code

## Before starting

Read in order:
1. `.agents/context/codebase/00-overview/README.md` — codebase state
2. `.agents/specs/` — existing specs (avoid duplicates)
3. `.agents/plans/` — existing plans (check dependencies)

## When to trigger

**Always trigger when** the task adds anything not yet in codebase:
new route / endpoint / entity / domain concept / module.

Do NOT use for: bug fix (→ `logs/fixes/LOG.md`), refactor without behavior change,
docs-only update.

---

## Stage 1 — Spec (draft → approved)

```bash
DATE=$(date +%Y-%m-%d)
SLUG="<feature-slug>"
cp ".agents/specs/_TEMPLATE.md" \
   ".agents/specs/${DATE}-${SLUG}-design.md"
```

Fill using actual layer names from this project (Flutter):
**domain/models → services → providers/notifiers → screens → widgets → test**

Set `Status: Draft` → present to user for review.
**Do not proceed to Stage 2 until user sets Status to `Approved`.**

## Stage 2 — Implementation Plan

```bash
cp ".agents/plans/000-TEMPLATE.md" \
   ".agents/plans/${DATE}-${SLUG}.md"
```

Fill task list per layer. Every task must have:
- Which file(s) it touches
- Acceptance criteria ("done when: ...")

## Stage 3 — Code

- Only after plan exists and spec is `Approved`.
- Update checklist as tasks complete: `- [ ]` → `- [x]`.
- Run `error-check` skill after each layer is done.

## Stage 4 — Done

- Set plan `Status: Done`
- Fill `## Walkthrough` (what was built, key files, how to test)
- Move out-of-scope ideas noticed during work → append to `.agents/logs/fixes/LOG.md`
  under `## Backlog` section

## Rules

1. No code before spec is `Approved` and plan exists.
2. Tasks must be small — independently committable.
3. Every task has acceptance criteria.
4. Checklist updated in real-time.
5. Check `.agents/context/codebase/10-gaps-and-recommendations/README.md`
   for constraints before starting (security, tenancy, etc.).
