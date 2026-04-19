# Purpose

This repository is an Android assessment app. The objective is to implement a minimal, correct product search flow using the existing app structure.

---

# Operating System

This repository is executed primarily on Windows.

Always prefer:

* PowerShell scripts (`.ps1`)
* `powershell -ExecutionPolicy Bypass -File ...`
* `.\gradlew.bat`

Do not assume:

* bash
* WSL
* Git Bash
* Unix utilities like `chmod`, `sed`, `grep`, or `rm`

---

# Hard Constraints

* Use Kotlin
* Use Jetpack Compose
* Use the existing `ProductService`
* Do not introduce Repository or UseCase layers
* Prefer minimal changes over broad rewrites
* Keep the solution simple and aligned with the assessment

---

# Required Workflow

For implementation tasks, always follow:

1. Inspect `README.md` and relevant source files
2. Plan the smallest viable change set
3. Implement incrementally
4. Run validation
5. Repair based on validation failures
6. Re-run validation
7. Produce a final review summary

Do not skip validation or final review.

---

# Validation (Canonical Definition)

The following commands define the **canonical validation contract** for this repository:

* `.\gradlew.bat :app:compileDebugKotlin`
* `.\gradlew.bat :app:testDebugUnitTest`
* `.\gradlew.bat :app:detekt`

These commands must be executed for any meaningful code change.

---

# Validation (Execution Method)

Validation should be executed via:

* `powershell -ExecutionPolicy Bypass -File .\scripts\validate.ps1`

## Requirements

* The script **must internally execute the canonical Gradle commands above**
* The script must **fail fast** on errors
* The script must produce deterministic results

If the script is missing or fails, fallback to running the canonical Gradle commands directly.

---

# Validation Artifact

Every validation run must produce:

* `.claude/reports/validation-status.json`

## Required format

```json
{
  "timestamp": "ISO-8601",
  "compile": "PASS | FAIL | NOT_RUN",
  "tests": "PASS | FAIL | NOT_RUN",
  "detekt": "PASS | FAIL | NOT_RUN",
  "overall": "PASS | FAIL",
  "summary": "human-readable summary"
}
```

## Rules

* `overall = PASS` only if all steps pass
* Any failure → `overall = FAIL`
* Do not claim success without a valid artifact

---

# Repair Rules

When validation fails:

* Fix only what validation indicates is broken
* Do not broaden scope
* Do not refactor unrelated code
* Keep changes minimal and targeted

---

# Final Review Requirements

Before completion, the result must include:

## Changed files

List all modified files

## Validation results

* compile
* tests
* detekt
* overall

## Confirmed behavior

What the user can expect after the change

## Remaining risks

Any known limitations or uncertainties

## Final recommendation

* READY FOR HUMAN REVIEW
  or
* NOT READY FOR HUMAN REVIEW

---

# Behavioral Rules

* Do not assume tools or environments not explicitly allowed
* Do not introduce unnecessary complexity
* Do not skip steps in the workflow
* Do not claim completion without validation
* Do not bypass the validation artifact requirement

---

# Philosophy

This repository prioritizes:

* determinism over convenience
* minimalism over abstraction
* correctness over speed
* explicit contracts over implicit behavior

All changes must respect these principles.
