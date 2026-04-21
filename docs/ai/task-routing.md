\# Task Routing



This document defines which AI agent or skill should be used for common Android development tasks in this repository.



The main objective is to keep agent scope narrow, improve reliability, and avoid mixing fundamentally different kinds of work.



\---



\## Core Routing Principle



Route work by problem type, not by convenience.



Prefer:

\- feature implementation agents for new functionality

\- bug investigation agents for defects

\- build-focused agents for Gradle or environment failures

\- review agents for review-only work

\- release agents for release-readiness work



Do not overuse a generic implementation agent when the problem is actually test, build, architecture, or performance specific.



\---



\## Task Classes



\### 1. Feature Work



\#### Route to

\- `android-feature-implementer`



\#### Examples

\- new screen

\- new user flow

\- UI behavior update

\- navigation change

\- API consumption change

\- state-management update



\#### Expected validation path

1\. `format.ps1`

2\. `validate-fast.ps1`

3\. `validate-module.ps1`

4\. `validate.ps1` before final completion



\---



\### 2. Bug Fix



\#### Route to

\- `android-bug-investigator`



\#### Examples

\- incorrect UI state

\- broken click behavior

\- navigation bug

\- repeated side effects

\- stale state or rendering defect

\- crash reproduction and repair



\#### Expected validation path

1\. `format.ps1`

2\. `validate-fast.ps1`

3\. `validate-module.ps1`

4\. `validate.ps1` before final completion



\---



\### 3. Test Work



\#### Route to

\- `android-test-engineer`



\#### Examples

\- add missing unit tests

\- repair broken unit tests

\- improve behavioral coverage

\- add targeted regression tests



\#### Expected validation path

1\. `format.ps1`

2\. `validate-fast.ps1`

3\. `validate-module.ps1`

4\. `validate.ps1` before final completion if the task is being closed



\---



\### 4. Build or Tooling Failure



\#### Route to

\- `android-build-doctor`



\#### Examples

\- Gradle task failure

\- AGP or Kotlin mismatch

\- dependency resolution failure

\- KSP or annotation-processing failure

\- SDK/JDK path issue

\- validation pipeline failure



\#### Expected validation path

1\. inspect current failing report or log

2\. apply smallest confirmed repair

3\. `validate-fast.ps1` or `validate-module.ps1`

4\. `validate.ps1` before final completion



\---



\### 5. Compose Review



\#### Route to

\- `android-compose-reviewer`



\#### Examples

\- review a Compose screen

\- assess state ownership

\- inspect recomposition risk

\- inspect side-effect usage

\- review UI maintainability



\#### Expected validation path

\- none if review-only

\- standard validation path if code changes are applied



\---



\### 6. Architecture Review



\#### Route to

\- `android-architecture-reviewer`



\#### Examples

\- boundary placement

\- ownership of business logic

\- dependency direction review

\- modularization review

\- change-scope trade-off review



\#### Expected validation path

\- none if review-only

\- standard validation path if code changes are applied



\---



\### 7. Performance Review



\#### Route to

\- `android-performance-reviewer`



\#### Examples

\- main-thread concerns

\- startup risk review

\- repeated work in UI flow

\- recomposition overhead

\- responsiveness concerns



\#### Expected validation path

\- none if review-only

\- standard validation path if code changes are applied



\---



\### 8. Analytics Validation



\#### Route to

\- `android-analytics-validator`



\#### Examples

\- duplicate beacons

\- missing events

\- payload inconsistency

\- event timing concerns

\- instrumentation review



\#### Expected validation path

\- none if review-only

\- standard validation path if code changes are applied



\---



\### 9. Release Readiness



\#### Route to

\- `android-release-assistant`



\#### Examples

\- final readiness review

\- merge readiness

\- risk summary

\- rollback-sensitive change review



\#### Expected validation path

\- canonical `validate.ps1` should already be current



\---



\## Escalation Rules



\### Escalate from feature implementation to build diagnosis when:

\- the main blocker is Gradle, dependency, SDK, or environment failure

\- validation fails before functional behavior can be judged



\### Escalate from feature implementation to test engineering when:

\- the change is complete but the main missing piece is test coverage or failing tests



\### Escalate from feature implementation to Compose review when:

\- the task changes meaningful Compose UI behavior

\- state ownership or side effects are non-trivial



\### Escalate to architecture review when:

\- a change introduces new ownership questions

\- a new boundary, package, or module is introduced

\- the smallest viable change still creates long-term coupling risk



\### Escalate to release review when:

\- the task is being handed off as complete

\- the task is high-risk or rollback-sensitive

\- the user asks for final readiness judgment



\---



\## Final Rule



The routing decision should optimize for correctness and narrow scope, not speed alone.



When in doubt:

\- implementation problems go to implementer

\- broken behavior goes to bug investigator

\- broken builds go to build doctor

\- missing coverage goes to test engineer

\- review-only work goes to the relevant reviewer

