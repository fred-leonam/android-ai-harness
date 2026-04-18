\---

name: implement-search-feature

description: Implement the unfinished product search flow in this Android assessment app

agent: android-implementer

\---



\# Skill: implement-search-feature



\## Use when

Implementing the unfinished search feature in this repository.



\## Inputs

\- `README.md`

\- `MainActivity`

\- `SearchViewModel`

\- `SearchScreen`

\- `ProductService`

\- existing tests



\## Constraints

\- Use Kotlin

\- Use Compose

\- Use the existing `ProductService`

\- Do not add Repository or UseCase layers

\- Keep implementation minimal and assessment-aligned



\## Procedure

1\. Read `README.md` and inspect unfinished files.

2\. Inspect `ProductService` behavior.

3\. Define minimal UI state:

&#x20;  - query

&#x20;  - loading

&#x20;  - products

&#x20;  - error

4\. Implement `SearchViewModel` using `StateFlow` and coroutines.

5\. Implement `SearchScreen` using Compose.

6\. Ensure `MainActivity` renders the screen.

7\. Add or update tests for key state transitions.

8\. Invoke `run-android-validation`.

9\. If validation fails, invoke `repair-from-sensors`.



\## Success criteria

\- compiles

\- tests pass

\- detekt passes

\- loading, success, and error states are handled

\- repository constraints are respected

