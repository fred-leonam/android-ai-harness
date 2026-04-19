---
name: run-android-validation
description: Run deterministic Android validation for this repo, summarize compile test and detekt results, and rely on validate.ps1 to write canonical validation artifacts
context: fork
agent: android-validator
---

# Skill: run-android-validation

Run validation for this Android repository and produce canonical validation artifacts.

## Validation commands
Always prefer Windows-native execution.

Run:
1. `powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1`

Do not use direct Gradle commands as the canonical validation path.

## Canonical artifacts
After validation completes, the canonical artifacts must exist:

- `.claude/reports/validation-status.json`
- `.claude/reports/validation-raw.log`

## Expected report schema
The report is owned by `scripts/validate.ps1` and must match the schema required by `CLAUDE.md`.

At minimum it must include:
- `timestamp`
- `started_at`
- `finished_at`
- `duration_ms`
- `generator`
- `schema_version`
- `compile`
- `tests`
- `detekt`
- `overall`
- `summary`
- `raw_log_path`
- `steps.compile`
- `steps.tests`
- `steps.detekt`

## Required output
Return:
- the command executed
- results per phase
- overall result
- path to the written JSON artifact
- path to the written raw log
- short failure summary when applicable