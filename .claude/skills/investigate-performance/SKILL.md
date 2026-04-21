\---

name: investigate-performance

description: Assess Android changes for startup cost, main-thread overhead, recomposition waste, and responsiveness risks

context: fork

agent: android-performance-reviewer

\---



\# Skill: investigate-performance



Review the current implementation area for meaningful performance risks.



\## Review checklist

1\. Main-thread work

2\. Repeated work

3\. Recomposition overhead

4\. Object churn and instability

5\. Startup or navigation overhead

6\. User-facing responsiveness risks



\## Rules

\- Focus on meaningful performance issues.

\- Avoid speculative micro-optimization.

\- Separate confirmed issues from hypotheses.



\## Deliverable

Return:

\- confirmed concerns

\- likely concerns

\- low-priority observations

\- recommended actions

\- current-scope acceptability

