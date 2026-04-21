\# AI Operating Model



This document defines how the AI harness operates in this Android repository.



It explains:

\- how work is structured

\- how responsibilities are separated

\- how validation is enforced

\- how agents should behave across different task types



This is the primary reference for understanding how to use AI safely and effectively in daily Android development work.



\---



\# 1. Core Philosophy



The harness is built around four principles:



\## 1. Smallest Viable Change

Always prefer the smallest change that correctly solves the problem.



Avoid:

\- broad refactors

\- speculative improvements

\- unrelated cleanup



\## 2. Separation of Responsibilities

Different types of work are handled by different specialized agents.



Do not use a single agent for all tasks.



Examples:

\- feature implementation ≠ bug fixing

\- bug fixing ≠ build diagnosis

\- implementation ≠ architecture review



\## 3. Validation as a First-Class Concern

Validation is not optional.



All meaningful work must eventually pass canonical validation.



\## 4. Protected Control Plane

The harness itself must remain stable.



Control-plane files are not part of normal feature work.



\---



\# 2. System Structure



The harness is composed of four main layers:



\## A. Control Plane



Defines rules and constraints.



Includes:

\- `CLAUDE.md`

\- `.claude/settings.json`

\- `.claude/settings.local.json`



Responsibilities:

\- enforce permissions

\- define validation rules

\- protect the system from unsafe changes



\---



\## B. Agents



Agents are specialized roles that perform work.



Each agent has:

\- a narrow mission

\- clear constraints

\- defined outputs



Examples:

\- android-feature-implementer

\- android-bug-investigator

\- android-build-doctor

\- android-test-engineer

\- android-compose-reviewer

\- android-architecture-reviewer

\- android-performance-reviewer

\- android-release-assistant

\- android-analytics-validator

\- android-validator



Agents do not decide \*what\* to do.  

They execute \*how\* to do it within their scope.



\---



\## C. Skills



Skills define \*\*when and why\*\* an agent is used.



Each skill:

\- routes to a specific agent

\- defines a workflow

\- defines constraints for that task



Examples:

\- implement-feature

\- fix-build

\- fix-test-failures

\- review-compose-screen

\- review-architecture

\- investigate-performance

\- validate-analytics

\- prepare-release

\- finalize-change



Skills are the entry point for task execution.



\---



\## D. Scripts



Scripts are the execution layer.



They perform:

\- validation

\- formatting

\- safety checks

\- report generation



Key scripts:

\- `format.ps1`

\- `validate-fast.ps1`

\- `validate-module.ps1`

\- `validate.ps1`

\- `require-validation-report.ps1`

\- `block-dangerous-command.ps1`



Scripts are the only allowed interface to:

\- Gradle execution

\- validation reporting

\- final completion verification



\---



\# 3. Execution Model



All work follows this lifecycle:



\## Step 1 — Understand the task

\- read requirements

\- inspect codebase

\- identify the correct task class



\## Step 2 — Route to the correct agent

Based on task type:

\- feature → implementer

\- bug → investigator

\- build failure → build doctor

\- test → test engineer

\- review → reviewer agents



\## Step 3 — Apply minimal change

\- implement or repair

\- do not broaden scope

\- follow local patterns



\## Step 4 — Validate incrementally

Use validation tiers:



\- Tier 0: formatting

\- Tier 1: fast validation

\- Tier 2: module validation



\## Step 5 — Final validation

Run:

\- `validate.ps1`



This produces the canonical validation report.



\## Step 6 — Final handoff

Produce structured output including:

\- what changed

\- validation results

\- risks

\- recommendation



\---



\# 4. Validation Model



Validation has four tiers:



\## Tier 0 — Formatting

\- fast

\- local hygiene only



\## Tier 1 — Fast validation

\- quick compile-level confidence

\- used frequently during development



\## Tier 2 — Module validation

\- validates affected module

\- used before task completion



\## Tier 3 — Canonical validation

\- full validation

\- required for completion



\---



\# 5. Completion Rules



A task is considered complete only if:



1\. Canonical validation (`validate.ps1`) was executed

2\. `.claude/reports/validation-status.json` exists

3\. The report:

&#x20;  - is well-formed

&#x20;  - is recent

&#x20;  - has overall = PASS



\---



\# 6. Validation Gate Behavior



The stop-time validation gate enforces correctness.



\## Canonical validation is required when:

\- production code changed

\- configuration changed

\- tests changed



\## Canonical validation is NOT required when:

\- only documentation changed

\- only reports changed

\- session is explicitly:

&#x20; - review-only

&#x20; - diagnosis-only

&#x20; - analysis-only



\---



\# 7. Routing Model



Work must be routed by problem type.



\## Correct routing examples



| Task | Agent |

|------|------|

| Implement feature | android-feature-implementer |

| Fix bug | android-bug-investigator |

| Fix Gradle/build issue | android-build-doctor |

| Add or repair tests | android-test-engineer |

| Review Compose UI | android-compose-reviewer |

| Review architecture | android-architecture-reviewer |

| Review performance | android-performance-reviewer |

| Validate analytics | android-analytics-validator |

| Prepare release | android-release-assistant |



\---



\# 8. Escalation Model



Escalation is required when the nature of the task changes.



\## Examples



\### From implementer → build doctor

When:

\- validation fails due to build issues

\- Gradle fails before feature behavior can be verified



\### From implementer → test engineer

When:

\- implementation is complete

\- remaining work is test-related



\### From implementer → reviewer

When:

\- correctness is not the only concern

\- architecture, performance, or UI behavior needs evaluation



\---



\# 9. Control Plane Protection



The following must never be modified during normal work:



\- `CLAUDE.md`

\- `.claude/settings.json`

\- `.claude/agents/\*\*`

\- `.claude/skills/\*\*`

\- `.claude/reports/\*\*`

\- validation scripts



These define the system itself.



Changes to them must be treated as:

\- explicit

\- isolated

\- intentional



\---



\# 10. Anti-Patterns



Avoid the following:



\## 1. Using the wrong agent

Example:

\- using implementer to fix Gradle failure



\## 2. Skipping validation

Example:

\- claiming completion without canonical validation



\## 3. Broad refactoring

Example:

\- rewriting modules when only a bug fix is needed



\## 4. Editing control-plane files

Example:

\- modifying CLAUDE.md during feature implementation



\## 5. Treating fast validation as final

Example:

\- relying only on validate-fast.ps1



\---



\# 11. Summary



This harness enforces a disciplined development model:



\- route work correctly

\- keep changes minimal

\- validate incrementally

\- enforce a strict final validation gate

\- protect the control plane



The system is optimized for:

\- reliability

\- clarity

\- reviewability

\- safe iteration



The most important rule:



\*\*No meaningful change is complete without canonical validation.\*\*

