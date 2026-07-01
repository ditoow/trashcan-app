# context/ — Project Reference

- **`product/`** — human-authored docs (PRD, requirements, diagrams). Drop files here or reference them.
- **`codebase/`** — AI-generated analysis. Regenerate when codebase changes significantly.

## codebase/ categories (02-09 created on demand)

Only `00-overview/`, `01-architecture/`, `10-gaps-and-recommendations/` exist by default.

| # | Folder | Create when... |
|---|---|---|
| 02 | `02-domain/` | Non-trivial domain entities (multi-tenant, billing, complex auth) |
| 03 | `03-infrastructure/` | Containers, IaC, cloud services, queues |
| 04 | `04-delivery/` | CI/CD pipelines, release process |
| 05 | `05-shared/` | Significant shared/common code across modules |
| 06 | `06-api/` | Documented public or internal API surface |
| 07 | `07-database/` | Database schema worth documenting |
| 08 | `08-observability/` | Logging, metrics, tracing, alerting |
| 09 | `09-devops/` | Deployment targets, infra-as-code, runbooks |
