\---

name: review-compose-screen

description: Review a Jetpack Compose screen for state ownership, side-effect correctness, and recomposition risk

context: fork

agent: android-compose-reviewer

\---



\# Skill: review-compose-screen



Review a Compose screen or UI change for correctness and maintainability.



\## Review checklist

1\. State ownership and hoisting

2\. Event flow clarity

3\. Side-effect usage

4\. Recomposition risks

5\. Separation of UI and business logic

6\. Testability and previewability



\## Rules

\- Focus on the most meaningful findings.

\- Separate confirmed issues from suggestions.

\- Do not perform broad implementation during review.



\## Deliverable

Return:

\- strengths

\- confirmed issues

\- likely risks

\- recommended minimal fixes

\- current-scope acceptability

