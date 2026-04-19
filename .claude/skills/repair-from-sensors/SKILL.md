---
name: repair-from-sensors
description: Repair only what compile test or detekt failures indicate is broken, then hand back for validation
context: fork
agent: android-repairer
---

# Skill: repair-from-sensors

Repair the implementation based only on validation failures.

## Inputs
Use:
- validation command output
- test failures
- detekt failures
- `.claude/reports/validation-status.json` if present

## Rules
- Repair only what the failing sensors indicate is broken.
- Do not broaden scope.
- Do not introduce new architecture layers.
- Preserve the assessment constraints.
- Prefer the smallest viable fix.
- Do not claim success without re-running validation.

## Operating system expectations
This repository is executed primarily on Windows.

Always prefer:
- PowerShell scripts (`.ps1`)
- `powershell -ExecutionPolicy Bypass -File ...`
- `.\gradlew.bat`

Do not assume:
- bash
- WSL
- Git Bash
- Unix utilities like `chmod`, `sed`, `grep`, or `rm`

## Deliverable
Return:
- what failed
- what was changed to repair it
- what still remains risky
Then hand back to validation.