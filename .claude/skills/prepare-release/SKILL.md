\---

name: prepare-release

description: Produce a release-readiness summary for an Android change including validation, risks, and rollback-sensitive concerns

context: fork

agent: android-release-assistant

\---



\# Skill: prepare-release



Assess whether the current change is ready for release review.



\## Review checklist

1\. Validation completeness

2\. User-visible behavior changes

3\. Remaining known risks

4\. Config or dependency impact

5\. Rollback sensitivity

6\. Test confidence



\## Rules

\- Be conservative.

\- Do not assume evidence that is missing.

\- Separate confirmed readiness from open questions.



\## Deliverable

Return:

\- readiness summary

\- validation status

\- user-visible impact

\- rollback considerations

\- blockers

\- recommendation

