---
name: breakdown
description: Breaks an approved epic into unit behaviors — one stub file per behavior, with complete scenarios (deterministic and semantic) and a minimal dependency graph — and shows the execution waves for the user to confirm. Use when the user says "breakdown", "break down the epic", "generate the behaviors", or when an approved EPIC.md has no behaviors/ yet. No technical plan is written here — planning happens at execution time.
---

# Breakdown: epic → behavior graph

Input: `specs/<epic>/EPIC.md`. Output: `specs/<epic>/behaviors/NNN-<slug>.md`, one per behavior,
in the format of `~/.claude/harness/FORMATS.md §5–6`, plus the wave table.

## 0. Gate

If the epic's **Open decisions** section is not empty (and not explicitly deferred by the user):
**STOP** and send it back to `/epic`. Do not guess — a behavior built on an open decision comes
back as rework.

## 1. One behavior → one stub file

For each behavior in the epic's list:

- **Frontmatter**: sequential zero-padded `id` · `epic` · action-first `title` · `depends_on` ·
  `status: pending` · `attempts: 0` · `ctx:`.
- **`ctx:` points at the WHY, not the code** (plan researches the code on its own, freshly, at
  execution time): the transcript or meeting that originated the behavior, the ADR that governs
  it, the rubric, the relevant part of the Contract. Inclusion test: *"would not reading this
  send the executor down the wrong path?"* If it is only background, leave it out — noise costs
  as much as absence.
- **Body**: Context / Trigger / Outcome, copied from the epic and **sharpened** — more specific,
  never vaguer.
- **Complete scenarios**: happy path + **every edge the epic implies** — empty, invalid,
  duplicate, unauthorized, external dependency failure. Each scenario with its type declared:
  `[deterministic]` or `[semantic · rubric X]`. Every scenario verifiable — by a program or by a
  judge. Format rules and the numeric-range warning: FORMATS §6.
- **Rubric seeds**: if `evals/rubrics/*.md` has a **Judged examples (seed)** section, convert each
  one into a scenario on the right behavior (with `ctx:` pointing at the origin of the judgment)
  and remove it from the rubric — the seed exists to become a scenario, not to accumulate.
- **NO Technical Plan.** By the time behavior 32 executes, behaviors 1–31 have changed the
  codebase — planning now is planning against code that will not exist.

## 2. Granularity check (the most common failure)

One behavior = one visible action, one context, one outcome.

- **Too big**: >~6 scenarios · "and" in the title · touches more than one
  screen/endpoint/command → split it.
- **Too small**: no observable result of its own → not a behavior, it is a step — it belongs in
  another behavior's Technical Plan.
- Yardstick: **can you demo it to the client on screen?**

### Monolithic system / pipeline — read FORMATS §1.1 before splitting

If the epic is a coupled pipeline (fetch → parse → judge → persist → notify), splitting by
**stage** is wrong: no stage is demonstrable, none has an observable result of its own, and all
depend in a chain (waves of 1 = bad graph).

Split by **path**: each behavior crosses the whole pipeline. Typical shape — one **heavy happy
path** (`depends_on: []`) plus a **fan of edges** that depend only on it (source down ·
duplicate record · input that should be discarded · the output report). A wave with one item is
normal here, as long as wave 2 has several.

Small epic → 3 behaviors, not 12. Genuinely indivisible → 1 behavior and granularity drops to
the scenarios. **Never invent behaviors to fill a quota.**

## 3. The dependency graph — minimal, always

- **Data dependency**: "delete post" depends on "create post" existing.
- **Structural dependency**: behaviors on a screen depend on the behavior that introduces the screen.
- **Keep it MINIMAL: every false dependency destroys parallelism.** Two behaviors in different
  zones are independent even if they "feel related".
- **Cycles are forbidden** — if one appears, the behaviors were badly split; re-split them.

## 4. Waves + confirmation

Compute and show the user:

```
| id  | behavior                          | depends_on |
...
Waves: 1 → 001, 002, 005 · 2 → 003, 004 · 3 → 006
```

- **Bad-graph signal**: waves of one behavior each — that is a queue disguised as a graph.
  Re-examine the dependencies before showing it.
- Ask for a quick confirmation. This is the only moment the user looks at the graph.
- Confirmed: update the index in `PLAN.md` and point at the next step — `/feature` (or the
  orchestrator, once it exists).
