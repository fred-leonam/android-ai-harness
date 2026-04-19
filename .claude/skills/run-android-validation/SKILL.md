---
name: run-android-validation
description: Run deterministic Android validation for this repo, summarize compile test and detekt results, and write a validation report artifact
context: fork
agent: android-validator
---

# Skill: run-android-validation

Run validation for this Android repository and produce a deterministic validation artifact.

## Validation commands
Always prefer Windows-native execution.

Run:
1. `powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1`

If the repository does not contain `.\scripts\validate.ps1`, then run the smallest equivalent Windows-native command set needed for:
- compile
- unit tests
- detekt

Use:
- `.\gradlew.bat`

## Required output
After validation completes, write this file:

- `.claude/reports/validation-status.json`

## Required JSON shape
```json
{
  "timestamp": "ISO-8601 timestamp with timezone",
  "compile": "PASS | FAIL | NOT_RUN",
  "tests": "PASS | FAIL | NOT_RUN",
  "detekt": "PASS | FAIL | NOT_RUN",
  "overall": "PASS | FAIL",
  "summary": "short human-readable summary"
}