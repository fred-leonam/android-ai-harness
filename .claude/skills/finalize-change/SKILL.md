\---

name: finalize-change

description: Perform final readiness review and produce a structured human handoff summary for this Android assessment change

context: fork

agent: android-reviewer

\---



\# Skill: finalize-change



Perform the final readiness review before human handoff.



\## Review checklist

1\. Requirement coverage

2\. Alignment with `CLAUDE.md`

3\. Minimality of changes

4\. Validation completeness

5\. Remaining technical risks

6\. User-visible behavior summary



\## Inputs

Review:

\- changed files

\- implementation summary

\- validation results

\- `.claude/reports/validation-status.json`



\## Rules

\- Do not perform broad new implementation in this skill.

\- Focus on final review and handoff quality.

\- If validation is missing or stale, clearly say so.

\- If risks remain, separate them from confirmed behavior.



\## Required output

Return exactly these sections:



\### Changed files

\- list of changed files



\### Validation results

\- compile

\- tests

\- detekt

\- overall



\### Confirmed behavior

\- short summary of what the user can expect now



\### Remaining risks

\- unresolved risks, if any



\### Recommendation

\- READY FOR HUMAN REVIEW

or

\- NOT READY FOR HUMAN REVIEW

