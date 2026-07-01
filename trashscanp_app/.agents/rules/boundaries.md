# Boundaries

> Most important file for preventing agent runaway.

## Always OK

- Run test suite, linter, build
- Create new files under `src/` or equivalent source dirs
- Fix lint errors, typos, formatting
- Append to `.agents/logs/` and `.agents/memory/decisions.md`

## Ask first

- Adding a new dependency
- Changing database schema or migrations
- Modifying CI/CD config
- Any change to auth / security logic
- Deleting files

## Never do

- Push directly to `main` or production branch
- Commit secrets, `.env`, or credential files
- Overwrite `.agents/specs/` or `.agents/plans/` files that are already `approved`
- Skip feature-workflow for new features
- Skip error-check before declaring a task done

## Protected paths

- _(list paths agents must not modify)_
