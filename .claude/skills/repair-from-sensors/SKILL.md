\---

name: repair-from-sensors

description: Repair implementation based on compile, test, or detekt failures

agent: android-repairer

\---



\# Skill: repair-from-sensors



\## Procedure

1\. Read the latest validation failure output.

2\. Classify failures:

&#x20;  - compile

&#x20;  - test

&#x20;  - detekt

3\. Prioritize:

&#x20;  - compile first

&#x20;  - tests second

&#x20;  - detekt third

4\. Map each failure to the smallest likely file surface.

5\. Patch only those files.

6\. Re-run `run-android-validation`.

7\. Repeat until green or retry budget is exhausted.



\## Rules

\- Do not rewrite broad parts of the repo for localized failures

\- Preserve existing behavior unless failure requires change

\- Do not add prohibited architecture layers

