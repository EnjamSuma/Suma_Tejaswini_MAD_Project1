# AI usage log

**Project:** Budget Bites (Project One, CSC 6360)
**Team:** Suma Enjam and Tejaswini Kolliboni
**AI assistant used:** Claude (Anthropic), in the Claude chat app
**Where it was used:** planning, drafting, and debugging help. The runtime app does not call any AI service. Lunch Lens is a plain Dart rule and runs only on the phone.

## How we used it

| Area | What the AI helped with | What we did ourselves |
|---|---|---|
| Proposal | Rephrased the Word proposal text and the low-fidelity wireframe images from the project briefs we pasted in | [Reviewed it together, changed wording, chose Budget Bites and the task split, filled in names, IDs and links, signed the statement] |
| Planning | Suggested the five-screen layout, the two-table data model, the ClickUp task list, and the day-by-day plan | [Created the repo and the ClickUp board, assigned owners and dates, updated cards with real status and comments] |
| Debugging | Explained errors we pasted in (for example the notification package version mismatch, the default `widget_test.dart` failing, and Chrome not supporting SQLite) | [We applied the fixes and confirmed them] |
| Git and process | Explained branches, commits, pull requests, and what to write in ClickUp comments and commit messages | [We made our own commits and reviewed each other's pull requests] |
| Documentation | Rephrased the README, AI_FEATURE.md and ARCHITECTURE.md from the project's actual results | [We checked each claim against the app, filled in real numbers, and edited the text] |

## What we checked ourselves

- We ran `flutter test` and the integration test and read the output. [Add the real results.]
- We tested the app on [phone model] and [second device or emulator], including airplane mode and a restart.
- We confirmed the double-tap save records one purchase.
- We recomputed the Lunch Lens evaluation numbers and compared them with the test output.
- We removed or marked as "not working" anything we could not make work.

## Responsibility

We are responsible for everything submitted. Each of us can explain every file in the repository, and our own contributions are traceable in the commit history and the ClickUp task comments.
