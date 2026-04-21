# Purpose

This repository uses an AI harness to support daily Android development work in a disciplined, reviewable, and validation-driven way.

The harness is designed to help with:
- feature implementation
- bug fixing
- test creation and repair
- build and tooling diagnosis
- Compose review
- architecture review
- performance review
- release-readiness review

The default goal is to make the smallest viable correct change and preserve a reliable final validation gate.

---

# Operating System

This repository is executed primarily on Windows.

Always prefer:
- PowerShell scripts (`.ps1`)
- `powershell -ExecutionPolicy Bypass -File ...`
- `.\gradlew.bat` only through approved scripts

Do not assume:
- bash
- WSL
- Git Bash
- Unix utilities like `chmod`, `sed`, `grep`, or `rm`

---

# Core Principles

1. Prefer the smallest viable change set.
2. Avoid speculative refactors.
3. Preserve existing architecture unless change is required.
4. Keep behavior intentional and reviewable.
5. Treat validation as part of the implementation workflow, not as an optional extra.
6. Do not claim completion without the required validation evidence.
7. Protect the harness control plane from normal feature work.

---

# Task Classes

This harness supports multiple task classes.

## 1. Feature work
Examples:
- new screen
- UI behavior change
- navigation change
- state-management update
- API consumption update

Primary route:
- `android-feature-implementer`

## 2. Bug fixing
Examples:
- broken UI behavior
- incorrect state
- repeated side effect
- crash repair
- navigation defect

Primary route:
- `android-bug-investigator`

## 3. Test work
Examples:
- add missing unit tests
- repair broken tests
- add regression coverage

Primary route:
- `android-test-engineer`

## 4. Build or tooling repair
Examples:
- Gradle failure
- dependency issue
- AGP or Kotlin mismatch
- SDK or JDK environment issue
- KSP or annotation processing issue

Primary route:
- `android-build-doctor`

## 5. Compose review
Examples:
- state ownership review
- side-effect review
- recomposition risk review
- UI maintainability review

Primary route:
- `android-compose-reviewer`

## 6. Architecture review
Examples:
- ownership review
- dependency direction review
- package or module boundary review
- change-scope trade-off review

Primary route:
- `android-architecture-reviewer`

## 7. Performance review
Examples:
- startup concern
- main-thread risk
- repeated work
- responsiveness concern
- recomposition overhead

Primary route:
- `android-performance-reviewer`

## 8. Release-readiness review
Examples:
- final handoff
- merge readiness
- risk summary
- rollback-sensitive review

Primary route:
- `android-release-assistant`

---

# Required Working Style

For all implementation or repair tasks:

1. Read `README.md`, this file, and relevant source files first.
2. Inspect nearby local patterns before editing.
3. Plan the smallest viable change set.
4. Implement or repair incrementally.
5. Use the appropriate validation tier during development.
6. Run canonical final validation before claiming meaningful completion.
7. Produce a structured final handoff when appropriate.

For review-only tasks:
- do not force implementation
- do not pretend review is validated code completion
- clearly separate confirmed findings from suggestions

---

# Harness Control Plane

The following files and directories are part of the harness control plane and must not be edited during normal implementation work:

- `CLAUDE.md`
- `.claude/settings.json`
- `.claude/settings.local.json`
- `.claude/agents/**`
- `.claude/skills/**`
- `.claude/reports/**`
- `scripts/validate.ps1`
- `scripts/require-validation-report.ps1`
- `scripts/write-validation-report.ps1`
- `scripts/block-dangerous-command.ps1`
- `scripts/ensure-claude-dirs.ps1`

If one of these files must change, treat that as a separate harness-maintenance task, not as normal feature work.

---

# Validation Model

This repository uses multiple validation tiers.

## Tier 0 — Formatting / Hygiene

Execution:
- `powershell -ExecutionPolicy Bypass -File .\scripts\format.ps1`

Purpose:
- lightweight normalization of changed files
- local hygiene only

Rules:
- may run frequently
- does not prove correctness
- does not satisfy task completion

---

## Tier 1 — Fast Validation

Execution:
- `powershell -ExecutionPolicy Bypass -File .\scripts\validate-fast.ps1`

Purpose:
- provide cheap inner-loop confidence during active development

Rules:
- intended for frequent use
- non-canonical
- should fail fast
- must not be used to claim final completion

Typical use:
- after meaningful local implementation progress
- after targeted bug-fix progress
- after small production code changes

Artifacts:
- `.claude/reports/validation-fast-status.json`
- `.claude/reports/validation-fast.log`

---

## Tier 2 — Scoped / Module Validation

Execution:
- `powershell -ExecutionPolicy Bypass -File .\scripts\validate-module.ps1`
- or module-specific invocation when supported

Purpose:
- validate the affected module or task surface before final completion

Rules:
- broader than fast validation
- cheaper than canonical full validation
- useful for daily task handoff confidence
- must not replace canonical final validation for meaningful completion claims

Typical use:
- feature completion checkpoint
- bug-fix completion checkpoint
- test-task completion checkpoint

Artifacts:
- `.claude/reports/validation-module-status.json`
- `.claude/reports/validation-module.log`

---

## Tier 3 — Canonical Final Validation

Execution:
- `powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1`

This is the single authoritative final validation path.

## Canonical validation contract

At minimum, canonical validation must execute:
- `.\gradlew.bat :app:compileDebugKotlin --rerun-tasks --no-build-cache --console=plain`
- `.\gradlew.bat :app:testDebugUnitTest --rerun-tasks --no-build-cache --console=plain`
- `.\gradlew.bat :app:detekt --rerun-tasks --no-build-cache --console=plain`

## Canonical validation rules

- `validate.ps1` is the single source of truth for final validation execution and reporting
- the canonical validation report must be generated by `validate.ps1`
- the report must not be created or edited manually
- the report must not be produced by any other script
- canonical validation is required for any meaningful production-relevant completion claim

## Canonical artifacts

Every canonical validation run must produce:
- `.claude/reports/validation-status.json`
- `.claude/reports/validation-raw.log`

---

# Final Completion Rule

A meaningful code or configuration task is not complete unless:

1. `validate.ps1` has been executed successfully
2. the canonical validation artifact has been generated by that run
3. the stop-time validation gate accepts the artifact as current, well-formed, and passing

Fast or scoped validation may increase confidence, but they do not replace canonical final validation.

---

# Validation Gate Behavior

The stop-time validation gate may allow a session to finish without canonical validation only when:
- no production-relevant files were changed, or
- the session is explicitly review-only, diagnosis-only, or analysis-only

For any production-relevant code or configuration change, canonical validation remains mandatory.

Production-relevant files include at minimum:
- `app/**`
- `config/**`
- `build.gradle.kts`
- `settings.gradle.kts`
- `gradle.properties`
- `local.properties`

---

# Routing Guidance

Route work by problem type, not by convenience.

Prefer:
- implementation agents for new functionality
- bug investigators for broken behavior
- test engineers for test-specific work
- build doctors for Gradle, environment, or validation failures
- reviewers for review-only work
- release assistant for final readiness judgment

Escalate when the current task surface changes:

- from implementer to build doctor when validation is blocked by build or environment failure
- from implementer to test engineer when the remaining work is test-specific
- from implementer to Compose reviewer when UI state or side-effect complexity becomes the main concern
- from implementer to architecture reviewer when ownership or coupling becomes unclear
- from implementation or repair flow to release assistant for final handoff

---

# Hard Constraints

- Use Kotlin for Android production code.
- Respect existing repository conventions.
- Do not introduce unnecessary new layers.
- Do not edit harness control plane files during normal task work.
- Do not use direct Gradle execution as the public validation interface.
- Do not claim final completion from fast or scoped validation alone.
- Do not broaden scope without justification.

---

# Output Expectations

For implementation or repair tasks, return:
- what changed
- files changed
- validation status
- assumptions made
- remaining risks

For review tasks, return:
- confirmed strengths
- confirmed issues
- likely risks
- recommended actions
- whether the current scope is acceptable

For final readiness review, return exactly:
- changed files
- validation results
- confirmed behavior
- remaining risks
- recommendation

---

# Summary

This harness is optimized for disciplined daily Android work.

The intended operating model is:
- make the smallest viable change
- use the correct specialist agent
- use the appropriate validation tier during iteration
- rely on canonical final validation for meaningful completion
- preserve trust in the final handoff by keeping the control plane protected