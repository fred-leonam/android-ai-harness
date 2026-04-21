\---

name: fix-test-failures

description: Repair broken Android tests or add missing targeted test coverage with minimal scope

context: fork

agent: android-test-engineer

\---



\# Skill: fix-test-failures



Repair failing tests or add the smallest necessary missing coverage.



\## Inputs

Use:

\- failing test output

\- relevant production files

\- existing local test patterns

\- validation reports when present



\## Rules

\- Keep production changes minimal.

\- Keep fixes targeted to the failing or uncovered behavior.

\- Reuse repository conventions.

\- Do not broaden scope beyond the test surface unless justified.



\## Deliverable

Return:

\- failing or uncovered behavior

\- tests changed

\- any production change made for testability

\- remaining gaps

Then hand back to validation.

