\---

name: finalize-change

description: Produce the final readiness report for human validation

agent: android-reviewer

\---



\# Skill: finalize-change



\## Procedure

1\. Confirm validation passed.

2\. Review changed files for requirement coverage.

3\. Check for unnecessary complexity or abstraction drift.

4\. Produce:

&#x20;  - changed files

&#x20;  - validation summary

&#x20;  - user-visible behavior summary

&#x20;  - unresolved risks

&#x20;  - final recommendation



\## Stop condition

Do not finalize if required validation is red.

