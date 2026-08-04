---
name: init-project
description: Installs the project harness in a repository — new or already in flight. Inventories the repo and the intake material (contract, kickoff transcript, brand guide), interviews the user via grill-with-docs about scope, out of scope, invariant rules and deadlines, then writes the map (AGENTS.md), the Contract + epic index (PLAN.md), the glossary and rubric v1. Use when the user says "start a project", "install the harness", "adopt this repo", "set up the plan for this project", or attaches a contract or kickoff transcript asking to structure a project. It does NOT specify epics or create behaviors — that is /epic and /breakdown.
---

# Install the harness in a project

You are assembling the **Contract** and the **map** of a project. You do not write code, do not
specify an epic and do not create behaviors in this skill.

Read before writing any file: **`~/.claude/harness/FORMATS.md`** (formats live there, not here)
and **`~/.claude/harness/PRINCIPLES.md §2`** (adoption — especially the rule that **the past is
never documented as behaviors** in a project already in flight).

How to communicate with the user: **`~/.claude/harness/PROFILE.md`**. Short version: they do not
read code or specs — every question you ask is self-contained and decidable without opening
anything.

## 1. Inventory — never ask what the repository answers

Before the first question:

- `README`, the stack manifest (`package.json`/`pyproject.toml`/equivalent), `docker-compose`,
  `.env.example`
- `git log --oneline -40` — what was done, in what order. **If there is no git or no commits,
  that is finding #1** (see §5)
- existing docs: `AGENTS.md`, `CLAUDE.md`, `CONTEXT.md`, `docs/`, ADRs, any old plan
- the material the user dropped (contract, transcript, PDF, Figma) — attached, at the root, or
  in `intake/`

**A project already in flight is the normal case, not the exception.** Reconstruct state from
the code: what is already delivered becomes an `[x]` epic in the index; what is half-done
becomes the `[-]` epic. Do not start from zero in a repo with months of work.

## 2. Interview — by actually invoking `grill-with-docs`

**Call the `grill-with-docs` skill (Skill tool)** and run this phase through it. It owns the
interview, the `CONTEXT.md` and the ADRs: one question at a time, with your recommendation
embedded, challenging ambiguous terms, cross-checking what the user claims against what the
code does, and recording each decision **the moment it crystallizes** — never accumulating for
the end.

> **Mode boundary.** `ponytail` is active in every session and **does not govern this phase**.
> Here it applies only to the size of what you write (do not invent epics nobody asked for, do
> not create speculative files) and **never to the depth of the investigation**. Ponytail itself
> says: *never be lazy about understanding the problem.*

Dig until you have, precisely:

- **the project outcome** in one sentence — how the client knows it succeeded
- **what is out of scope** — the field nobody writes and the biggest source of rework
- **the invariant business rules** — what the system must never do
- **the project deadline** (not per behavior — there are no per-behavior deadlines)
- **the epics, in order** — a name plus ONE sentence each. Between 3 and 8. **Specify none of
  them**: specification is late, it happens in `/epic` when its turn comes
- **the sensitive zone** — where money, persisted data or authentication live
- **ambiguous terms** — "user", "account", "order": which of the two is it? The grill records it
  in the glossary

When a fact is missing that only the user or the client has, mark `[??: concrete question]` and
move on. Say in chat how many marks you left.

## 3. If the product is an AI system: rubric v1 + seeds

Harvest from the kickoff itself: when the client says *"this case we would take, this one we
wouldn't"*, **that is ground truth with provenance, not an anecdote**.

- Write `evals/rubrics/<capability>.md` (format in FORMATS §9): what the system decides, what
  correct means, the failure classes, what is outside the judgment.
- Concrete judgments captured now go in the **Judged examples (seed)** section of the rubric —
  `/breakdown` converts them into scenarios once behaviors exist.
- The rubric belongs to the **client**, not to you. Without their validation →
  `[??: validate with client]` in the header + a line in 🔴.

## 4. Write the files

Only what has real content (lazily — an empty folder looks filled in):

1. **`AGENTS.md`** — the map, ~40 lines, **routing only, no rules**: what the repo is · stack
   and commands · the operating loop (work enters through `/feature`, external input through
   `/intake`, a new epic through `/epic`; work state in `specs/*/behaviors/`) · where to look
   (PLAN, CONTEXT, adr, rubrics) · the sensitive zone. Plus a one-line `CLAUDE.md`: `@AGENTS.md`.
2. **`PLAN.md`** — Contract + 🔴 + **epic index** (FORMATS §3). Remember: a future epic is a
   name plus one line, never more.
3. **`CONTEXT.md` and `docs/adr/`** — the grill already wrote these during the interview.
4. **`intake/`** — archive what the user provided, dated, following the pattern
   `YYYY-MM-DD-<slug>.md` (full transcript, never edited).

## 5. The git gate — first item in 🔴

The entire workflow (verify, review, per-attempt reset, orchestrator) operates on commits and
branches. If the repo has no git or no commits:

- Assemble a **default-deny `.gitignore` for confidential material**: `.env*`, `intake/`,
  client data (spreadsheets, loose PDFs, exports).
- Leave the commands ready (`git init` if needed, `git add`, the initial commit) — **you do not
  execute: the user runs them.**
- Prove it before proposing: `git add -A --dry-run | grep -iE '\.env|intake/|\.xlsx|\.pdf'` must
  come back empty.
- Record it as the **first line of 🔴**: nothing runs through the cycle without it.

## 6. Close

In chat, self-contained: the epics in order (with the current `[-]`), the open `[??]` marks,
what you assumed, the state of the git gate, and the next step — `/epic` on the `[-]` epic.
