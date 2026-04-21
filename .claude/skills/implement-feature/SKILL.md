\---

name: implement-feature

description: Implement an Android feature change with the smallest viable repo-scoped modification

context: fork

agent: android-feature-implementer

\---



\# Skill: implement-feature



Implement the requested Android feature with minimal and reviewable changes.



\## Required workflow

1\. Read `README.md`, `CLAUDE.md`, and relevant source files first.

2\. Inspect nearby patterns before editing.

3\. Plan the smallest viable change set.

4\. Implement incrementally.

5\. Hand off to validation.

6\. If validation fails, route to repair instead of broadening scope.



\## Rules

\- Keep scope tight.

\- Avoid speculative refactors.

\- Preserve existing architecture unless a change is required.

\- Do not edit harness control plane files unless explicitly requested.



\## Deliverable

Return:

\- what was implemented

\- files changed

\- assumptions

\- risks requiring validation

