\---

name: run-android-validation

description: Run compile, unit tests, and detekt for the Android app

agent: android-validator

\---



\# Skill: run-android-validation



\## Procedure

1\. Run `powershell -ExecutionPolicy Bypass -File .\\scripts\\validate.ps1`

2\. Summarize results as:

&#x20;  - compile: PASS/FAIL

&#x20;  - tests: PASS/FAIL

&#x20;  - detekt: PASS/FAIL

3\. Extract the most relevant failure lines if any.

4\. If validation fails, invoke `repair-from-sensors`.

5\. If validation passes, hand off to `android-reviewer`.



\## Rules

\- Never assume validation passed

\- Never suppress failures

\- Prefer concise, structured output

\- Tests must show `N tests executed` in output or in the XML results under `app/build/test-results/`. A result of `UP-TO-DATE` means tests did NOT run — treat it as a failure and re-run with `--rerun-tasks`.

