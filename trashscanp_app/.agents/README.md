# .agents/ — Map

Shared context store for AI agents on this project.

| Folder | Purpose | Updated by |
|---|---|---|
| `rules/` | Coding conventions, comms style, boundaries | Human (setup), agents propose edits |
| `context/product/` | PRD, requirements, design docs | Human |
| `context/codebase/` | AI-generated codebase analysis | Agent (analysis pass) |
| `memory/decisions.md` | Architecture Decision Records | Agent + human |
| `memory/user.md` | Learned preferences (gitignored) | Agent |
| `specs/` | Feature specs — what to build | Human + agent |
| `plans/` | Implementation plans — how to build | Agent + human |
| `skills/` | Project-specific reusable workflows | Human + agent |
| `logs/fixes/` | Bug fix log + backlog | Agent |
| `personas/` | Optional specialized agent roles | Human |

## Reading order for new session

1. `AGENTS.md` (project root) — self-check gate first
2. `.agents/rules/` — constraints before doing anything
3. `.agents/context/codebase/00-overview/README.md` — orient on codebase
4. Relevant `.agents/specs/` or `.agents/plans/` for current task

## Notes

- Re-running `init-agents` is safe — existing files never overwritten.
- `.agents/` is committed to version control **except** `memory/user.md` (gitignored).
