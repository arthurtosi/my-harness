# How we work

> Loaded in **every** session. It is a **map, not a manual**: it only routes and lists what
> must not fail. The detail lives in `~/.claude/harness/` and loads on demand — loading it all
> at boot wastes the window and degrades recall.

## Vocabulary — three levels, three words

**Project → Epic → Behavior.** Dead words, never use: ~~slice~~ ~~task~~ ~~PRD~~ ~~issue~~.
**Nothing exists below a behavior** — technical work lives in the Technical Plan inside the
behavior file, written at execution time, and is never managed by the user.

- **Behavior** = a visible action, in a specific context, with an observable result.
  Test: can you demo it to the client on screen? "And" between two actions → it is two.
- **Epic** = one complete cycle of value (the user could not, now they can). 1 PR.

## Routing

| Situation | Skill |
|---|---|
| new project, or adopting an existing repo | `/init-project` |
| specify the next cycle of value | `/epic` |
| approved epic → behaviors + graph | `/breakdown` |
| do the work (the daily loop) | `/feature` |
| any external input: transcript, screenshot, email, contract | `/intake` |
| close an epic before merging | `/review` |
| semantic battery, score, regression | `/eval` |
| triage `HARNESS.md` into improvements | `/harness` |
| technical decision no ADR governs | `grill-me` |
| project start, or reopening a decision | `grill-with-docs` |
| writing code (posture, always active) | `ponytail` |

## Rules that must not fail

The reason behind each: `~/.claude/harness/PRINCIPLES.md`. Formats: `FORMATS.md`.

1. **No code change without a behavior.** A loose request in a repo with `PLAN.md` becomes a
   behavior (stub + scenarios) **before** it becomes code.
2. **The scenario is the contract.** Verifiable by a program **or** by a judge against a
   versioned rubric. "Vibes" are forbidden. `done` is verify's verdict, never the executor's.
3. **Write the least code possible.** Mandatory reuse gate before writing anything: internal
   (does a function already exist?) then external (is there a maintained popular library?).
   Preference: use as is > extend with a parameter > extract the common part > write new.
4. **Never weaken a test to make it pass; never mock what is under test.**
   A red test means the code is wrong, until the spec changes by human decision.
5. **A `done` behavior is never rewritten.** Something delivered changed → new behavior.
6. **On failure: reset, not patching.** Failure Report (4 fields), the attempt's code
   destroyed, fresh session. Max 3 — then escalate, with no fourth attempt.
7. **Specification is late.** A future epic is a name plus one line. The technical plan is born
   at execution time. Do not specify what has not had its turn.
8. **Do not document the past as behaviors** in a project already in flight. Already delivered
   = one `[x]` line in the index. A behavior only exists from now on.
9. **Write state before responding** — compaction is unannounced. What is not in a file does
   not exist.
10. **Secrets and client data never in git.** `.env*`, `intake/`, client spreadsheets and PDFs:
    default-deny `.gitignore` from the first commit.
11. **The AI does not execute** delete, install, deploy or force-push — it hands over a
    ready-to-run command for the user.

## The user

Who they are, how to communicate with them, and their preferences: **`~/.claude/harness/PROFILE.md`**.
Read it when the answer involves *how* to talk to them, escalate to them, or hand work over.
Short version: they read the chat, the Contract and the 🔴 panel — not code, not specs. Every
question to them is self-contained. Human validation is a batch, not a step.

## Where the rest lives (on demand, never at boot)

- `~/.claude/harness/FORMATS.md` — every format in the workflow
- `~/.claude/harness/PRINCIPLES.md` — the reasoning + adoption (new and existing projects)
- `~/.claude/harness/PROFILE.md` — who the user is and how to communicate
- `~/.claude/harness/LAYERS.md` — tools evaluated and rejected, with the trigger to reopen
- `~/.claude/harness/LEDGER.md` — global framework changes (written only by `/harness`)
