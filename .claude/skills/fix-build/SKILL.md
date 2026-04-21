\---

name: fix-build

description: Diagnose and repair Android build or validation failures using the smallest confirmed fix

context: fork

agent: android-build-doctor

\---



\# Skill: fix-build



Diagnose and repair the current Android build or validation failure.



\## Inputs

Use:

\- validation command output

\- raw logs

\- `.claude/reports/validation-status.json` when present

\- nearby Gradle and configuration files



\## Rules

\- Trust sensors over intuition.

\- Fix only the confirmed failure surface.

\- Distinguish repo issues from local environment issues.

\- Do not perform broad cleanup or unrelated refactors.



\## Deliverable

Return:

\- what failed

\- root cause

\- classification of issue

\- repair applied

\- remaining risk

Then hand back to validation.

