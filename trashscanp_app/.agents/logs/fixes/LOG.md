# Fixes Log

Append-only. Newest entry on top. Keep each entry to 3-5 lines.
Before fixing any bug: `grep -i "<keyword>" .agents/logs/fixes/LOG.md`

After each fix, also sync to global:
- Check `~/.agents/fixes/<tag>.md` — append same entry if exists, create if not.
- Same 3-5 lines, no extra elaboration.

---

## Backlog

_(Out-of-scope ideas noticed during work — append, don't act on now)_
- [ ] <idea> — source: plans/YYYY-MM-DD-<slug>.md

---

<!-- New entry format (newest on top):

## YYYY-MM-DD: <short title>
- **Symptom**: <what was observed>
- **Root cause**: <why it happened>
- **Fix**: <what changed — file refs>
- **Tags**: <keywords: auth, jwt, db, timeout, etc.>

-->
