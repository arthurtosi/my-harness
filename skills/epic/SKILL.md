---
name: epic
description: Specifies ONE epic — a complete cycle of value — when its turn comes, producing EPIC.md in functional language. Forks between an interview (business logic) and a disposable prototype (interaction/UI). Before specifying, it revalidates whether the epic still makes sense against what has already been delivered. Use when the user says "next epic", "let's specify", "new epic", "specify delivery X", or when the [-] epic in PLAN.md has no EPIC.md yet. It does NOT break the epic into behaviors — that is /breakdown.
---

# Specify an epic

Input: one epic from the `PLAN.md` index (the `[-]` one, or whichever the user names).
Output: `specs/<epic>/EPIC.md` — format in `~/.claude/harness/FORMATS.md §4`.
**Functional language only**: what users do and see. Zero technical terms.

## 0. Revalidation gate — before specifying anything

This is the built-in review point for the plan — the only moment where being wrong is still
free, because it is right before investing in specification. Read the Contract, the epic index
and what has already been delivered, then ask the user, self-contained:

> *Does this epic still make sense as written? Is it still the right one next? Did anything
> already delivered change one of its assumptions?*

If the answer changes the index (reorder, kill, insert an epic), **update `PLAN.md` first** — it
costs one line — and only then continue. A dead epic goes to `### Dead` with date and reason; it
never just disappears.

## 1. The fork — first question

> **Is this epic heavy on business rules, or on interaction?**

- **Business rules** (calculation, eligibility, decision flow, policy) → **interview** (§2).
- **Interaction** (screen, navigation, form — the user needs to SEE it to be able to specify it)
  → **prototype** (§3).
- Mixed: start with the dominant one; if business rules take over mid-prototype, pause and run
  the interview for that part — both outputs merge into a single EPIC.md.

## 2. Interview mode

You extract behaviors in the form **context + trigger + outcome**, nailing down every edge the
user has an opinion about — so `/breakdown` does not come back with questions.

- Rounds of **at most 3–4 questions**, each with **concrete proposed options** (multiple choice
  forces decisions; open questions invite vagueness). Use `AskUserQuestion` when available.
- Cover, in order: **who** uses it and **where** it lives (screen/command/endpoint) → the
  **happy path** as behaviors → the **edges** of each one (empty, invalid, duplicate,
  unauthorized, failure — propose specific answers: *"show an inline error 'email already
  registered'?"*) → what is explicitly **out**.
- **Converge in ≤3 rounds.** Stop when you can state every behavior with an observable outcome,
  unambiguously.
- A domain term defined or sharpened along the way → record it in `CONTEXT.md`; a decision that
  passes the three ADR tests → an ADR. The conventions are `grill-with-docs`' — follow its
  formats (`CONTEXT-FORMAT.md` / `ADR-FORMAT.md`).

## 3. Prototype mode

For interaction, words come **after** the artifact: build, iterate, then reverse-engineer the
approved version.

- Clarify only the minimum for a first draft (one round of questions, max).
- Build it in `specs/<epic>/prototype/`: **web → ONE self-contained HTML file** (inline CSS/JS,
  fake in-memory data, opens on double-click); CLI/API → a single end-to-end mock script. Every
  interaction genuinely clickable: buttons act, states change, errors show. All persistence
  faked. **Do not polish code quality** — iteration speed is the whole point.
- Iterate: *"click through it and tell me what's wrong"*. Apply fast. That is the entire phase.
- Approved → write the EPIC.md **from the prototype**: screen by screen, interaction by
  interaction, each becoming a behavior (context + trigger + outcome), including the empty
  states and errors the prototype demonstrates.

**Hard rule — the prototype is disposable BY CONTRACT:** it is never merged, imported or
"promoted" to production. The implementation reimplements the behaviors inside the real
architecture. Prototype code was optimized for iteration speed; letting it in poisons the
codebase — which is a prompt. It stays in `prototype/` as visual reference only.

## 4. Close

1. Write `specs/<epic>/EPIC.md` (FORMATS §4). The behavior list is **unitary**: one behavior
   implemented or one modified per item; a line with "and" between two user actions splits in two.
2. **Open decisions must be empty** — or each item explicitly deferred by the user. Open ≠ forgotten.
3. Read it back to the user: one paragraph plus the behavior list. Ask for approval.
4. Approved: mark the Source, update the index in `PLAN.md`, and point to the next step —
   `/breakdown`.
