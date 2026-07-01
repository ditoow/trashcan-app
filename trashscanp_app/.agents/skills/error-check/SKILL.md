---
name: error-check
description: Run after any code change to verify no errors before declaring done.
  Invoke on "cek error", "verify", "check build", "done?", or automatically after
  each feature-workflow stage.
metadata:
  domain: workflow
  triggers: cek error, verify, check build, selesai?, done
  role: process
  related-skills: feature-workflow
---

# Error Check

Run these steps in order. Never skip silently — if a step fails, fix before continuing.

1. **Build:** `<not detected>`
2. **Lint:** `<not detected>`
3. **Test:** `<not detected>`

If any command is listed as `<not detected>`, check `AGENTS.md` for the correct
command and update this file.

## After all steps pass

- Update plan checklist: mark error-check task as `- [x]`
- Add one line to `## Changelog` in every file you modified today
