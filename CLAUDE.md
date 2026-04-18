# CLAUDE.md

## Purpose
This repository is an Android assessment app. The objective is to implement a minimal, correct product search flow using the existing app structure.

## Operating system
This repository is executed primarily on Windows.

The target scripting environment is PowerShell, but Claude may invoke commands through a Bash wrapper.
Because of that:

Always prefer:
- PowerShell scripts (`.ps1`)
- `powershell -ExecutionPolicy Bypass -Command "..."`
- forward-slash paths in Claude-facing command strings, for example:
  - `./scripts/validate.ps1`
  - `./gradlew.bat`

Do not assume:
- WSL is available
- Git Bash-specific utilities are required
- Unix tools like `chmod`, `sed`, `awk`, or `rm` are available for implementation logic

## Hard constraints
- Use Kotlin
- Use Jetpack Compose
- Use the existing `ProductService`
- Do not introduce Repository or UseCase layers
- Prefer minimal changes over broad rewrites
- Keep the solution simple and aligned with the assessment

## Required workflow
For implementation tasks:
1. Inspect `README.md` and relevant source files first
2. Plan the smallest viable change set
3. Implement incrementally
4. Run validation
5. Repair from sensor failures
6. Re-run validation
7. Produce a final review summary

## Validation commands
Always use these commands for meaningful code changes:
- `powershell -ExecutionPolicy Bypass -Command "& ./scripts/validate.ps1"`

The validation script is the source of truth and is expected to run:
- `./gradlew.bat :app:compileDebugKotlin`
- `./gradlew.bat :app:testDebugUnitTest`
- `./gradlew.bat :app:detekt`

## Subagent routing
- Use `android-implementer` for feature implementation
- Use `android-validator` for validation and sensor reporting
- Use `android-repairer` for failed validation repair loops
- Use `android-reviewer` for final readiness review

## Output expectations
Before stopping, provide:
- changed files
- validation results
- unresolved risks
- short summary of user-visible behavior

## Safety and scope rules
- Do not modify unrelated files
- Do not delete large directories
- Do not change Gradle structure unless needed for validation
- Do not fabricate passing validation results
- If blocked, report the blocker concisely instead of guessing