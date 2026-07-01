# personas/

Optional specialized agent roles. Example `qa.md`:

```markdown
# Persona: QA
When operating under this persona:
- Prioritize edge cases and failure modes over happy-path.
- For every change, ask: "what test would catch a regression here?"
- Don't fix unrelated issues — log them in `context/codebase/10-gaps-and-recommendations/`.
```

Empty by default — add as specialized roles become needed.
