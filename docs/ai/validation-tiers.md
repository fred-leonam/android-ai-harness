\# Validation Tiers



This repository uses multiple validation tiers for different stages of work.



The goal is to preserve fast iteration during development while keeping a strict final completion gate.



\---



\## Tier 0 — Formatting / Hygiene



\### Script

\- `powershell -ExecutionPolicy Bypass -File .\\scripts\\format.ps1`



\### Purpose

Apply lightweight normalization to changed files.



\### Characteristics

\- fast

\- local

\- non-canonical

\- does not prove correctness

\- does not satisfy final completion requirements



\### Typical use

\- automatically after file edits

\- before running any validation tier



\---



\## Tier 1 — Fast Validation



\### Script

\- `powershell -ExecutionPolicy Bypass -File .\\scripts\\validate-fast.ps1`



\### Purpose

Provide cheap early confidence during the inner development loop.



\### Characteristics

\- faster than full validation

\- intended for frequent use

\- non-canonical

\- should fail fast

\- should not overwrite final validation artifacts



\### Typical checks

\- compile path for the main affected module or app

\- small, high-signal validation only



\### Artifacts

\- `.claude/reports/validation-fast-status.json`

\- `.claude/reports/validation-fast.log`



\### Typical use

\- after meaningful implementation progress

\- before escalating to scoped or canonical validation



\---



\## Tier 2 — Scoped / Module Validation



\### Script

\- `powershell -ExecutionPolicy Bypass -File .\\scripts\\validate-module.ps1`



\### Purpose

Validate the affected module or task surface before claiming the task is nearly complete.



\### Characteristics

\- broader than fast validation

\- cheaper than canonical full validation

\- non-canonical for final completion

\- useful for daily task handoff confidence



\### Typical checks

\- module compile

\- module unit tests

\- module Detekt or equivalent static analysis



\### Artifacts

\- `.claude/reports/validation-module-status.json`

\- `.claude/reports/validation-module.log`



\### Typical use

\- feature completion checks

\- bug-fix completion checks

\- test-task completion checks



\---



\## Tier 3 — Canonical Final Validation



\### Script

\- `powershell -ExecutionPolicy Bypass -File .\\scripts\\validate.ps1`



\### Purpose

Act as the single authoritative validation gate for final completion.



\### Characteristics

\- canonical

\- required for claiming final completion

\- writes the final authoritative validation artifacts

\- enforced by the stop-time validation gate



\### Canonical checks

The canonical validation contract is defined in `CLAUDE.md`.



At minimum, it must execute:

\- `.\\gradlew.bat :app:compileDebugKotlin --rerun-tasks --no-build-cache --console=plain`

\- `.\\gradlew.bat :app:testDebugUnitTest --rerun-tasks --no-build-cache --console=plain`

\- `.\\gradlew.bat :app:detekt --rerun-tasks --no-build-cache --console=plain`



\### Canonical artifacts

\- `.claude/reports/validation-status.json`

\- `.claude/reports/validation-raw.log`



\### Typical use

\- final human handoff

\- release-readiness review

\- completion claims for meaningful code changes



\---



\## Final Completion Rule



A change is not considered complete unless canonical validation has been executed successfully and the canonical artifacts are current.



Fast or scoped validation may increase confidence, but they do not replace canonical final validation.

