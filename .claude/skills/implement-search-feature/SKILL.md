---
name: implement-search-feature
description: Implement the unfinished product search flow in this Android assessment app with minimal repo-scoped changes
context: fork
agent: android-implementer
---

# Skill: implement-search-feature

Implement the unfinished product search flow in this Android assessment app.

## Required workflow
1. Inspect `README.md`, `CLAUDE.md`, and the relevant source files first.
2. Plan the smallest viable change set.
3. Implement incrementally.
4. Keep the solution aligned with the assessment constraints.
5. Do not broaden scope unless required to make the feature work.

## Hard constraints
- Use Kotlin.
- Use Jetpack Compose.
- Use the existing `ProductService`.
- Do not introduce Repository or UseCase layers.
- Prefer minimal changes over broad rewrites.
- Keep the solution simple and aligned with the assessment.

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
Produce the implementation changes only.
Do not claim completion until validation has run successfully or failures have been clearly reported for repair.