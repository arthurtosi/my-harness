---
name: harness
description: Triages the project's HARNESS.md — the telemetry the agent wrote about what the environment lacked and where the process cost extra — corroborates each line, decides whether the fix is LOCAL (glossary, ADR, map, behavior) or GLOBAL (a skill, hook or format in ~/.claude, affecting every project), cross-references the cross-project ledger, proposes a numbered diff for the user to approve in one batch, and removes from the file whatever was promoted. Use when the user says "/harness", "review the HARNESS", "triage the telemetry", "what should we improve in the workflow", or when HARNESS.md passes ~15 lines.
---

# Triage HARNESS.md

`HARNESS.md` is a channel of **candidates, not truths** (format:
`~/.claude/harness/FORMATS.md §12`). The agent writes to it during work; this skill is the only
place that **consumes** it.

Without this triage the file grows and rots — and then the framework stops generating improvement
and starts generating guilt. It is a queue, not an archive: **a promoted line leaves the file.**

## 0. Read the global ledger FIRST

`~/.claude/harness/LEDGER.md` — always, before looking at the project's `HARNESS.md`. It carries
three lists and each changes what you will propose:

- **Applied** → do not re-propose what already changed; and if friction here contradicts an applied
  change, **that is a finding**: the global change made something worse. Report it.
- **Candidates** → friction seen once in another project. **If it matches friction in the current
  triage, that is a CROSS-PROJECT pattern: promote now, do not wait for a 2nd local occurrence.**
  Friction repeating across different projects is the strongest signal that the flaw belongs to the
  framework, not the project.
- **Rejected** → the user already said no. Do not come back, unless there is new evidence (say what it is).

## 1. Read and corroborate BEFORE proposing

Every line is a claim. Before promoting anything to project truth:

- **LEARNING** ("the field has a 5th value", "the date comes in format X") → **confirm it in the
  code, the schema or real data.** Not confirmed? Do not promote: either mark it `[??]` for the user
  to decide, or discard it with a note.
- **MISTAKE** → what matters is the fact behind it, not the error. *"I assumed ISO and it broke"* is
  worth promoting if the real format ends up documented.
- **DESIRE** → no corroboration needed (it is a request, not a claim), but it needs classifying: is
  it missing **tooling**, missing **documentation**, or is it **product in disguise**?
- **FRICTION** → **not corroborated line by line: aggregated.** It is the one section where the value
  is in the **pattern**, not the item. See §1.1.

**Repetition is priority.** The same pain appearing 2+ times (different dates) is the strongest
signal in the file — handle it first, regardless of order.

### 1.1 FRICTION — read it as a series, not a list

A single FRICTION line almost never justifies action: *"this behavior cost 3 attempts"* could be bad
luck. **Three similar lines are a diagnosis.** Before proposing anything, aggregate and count:

| Pattern | Diagnosis | Where it gets fixed |
|---|---|---|
| 2+ behaviors failing on the **1st attempt** from an ambiguous scenario | **bad specification, not bad execution** | a rule in `/breakdown` or `/epic`: which class of ambiguity got through? |
| 2+ mutation audits catching weak tests | the tests systematically assert the wrong thing | a rule in `/feature` about what to assert |
| the same module touched by 3+ behaviors | **a missing abstraction** or a wrong decomposition | the abstraction pass in `/review` · or revisit how the epic was split |
| 2+ inconclusives on the same rubric criterion | a vague criterion — name the undefined word | the **rubric**, with the client. Version bumps |
| a semantic scenario that could have been deterministic | it cost tokens on every run for nothing | a rule in `/breakdown`: push more toward deterministic |
| an empty `External` line + a lot of custom code, repeatedly | **the reuse gate is being satisfied shallowly** | strengthen the gate in `/feature`, or it is a real ecosystem gap |

**A pattern pointing at a skill or a hook is the most valuable promotion in the file** — it is the
framework fixing itself instead of only fixing code.

### 1.2 Every line passes the LOCAL vs GLOBAL test

For **each** item you are about to propose (not just FRICTION), decide the scope:

> **Is this a quirk of this project, or a framework flaw that happened to surface here?**

| Signal | Scope | Fix |
|---|---|---|
| depends on this project's domain, stack or client | **local** | `CONTEXT.md` · ADR · `AGENTS.md` · a behavior |
| it is about **how the process works** — what a skill instructs, what a hook checks, what a format requires | **GLOBAL** | a file in `~/.claude/`, and it goes to the ledger |
| it already appeared **in another project** (ledger, §0) | **GLOBAL, no waiting** | same |
| appeared once and is about the process | **global candidate** | the *Candidates* section of the ledger, with project and date |

Quick test: *if I opened a brand-new project tomorrow, from scratch, would this problem happen
again?* Yes → global.

### 1.3 A global change: propose, never apply alone

A change in `~/.claude/` affects **every** project, present and future. So:

- **Propose with surgical precision**: which file, which section, the text **before → after**, and
  how many projects are affected. A vague proposal ("improve /breakdown") is unacceptable.
- **Wait for explicit approval.** No "I applied it and here's a heads-up".
- Approved: apply it, and **record it under *Applied*** in the ledger with what motivated it.
- Rejected: **record it under *Rejected*** with the reason — that is what keeps the proposal from
  returning every week.
- **Find where the framework actually lives before committing.** The files under `~/.claude/skills/`,
  `hooks/` and `harness/` may be **symlinks into a separate repository** (the recommended setup: one
  source of truth, clonable by others). Resolve the real path (`readlink -f <file>`), find its git
  root, and leave the commit command ready for that repo — not for `~/.claude`. If nothing is under
  git, say so once: changing the framework without rollback is unnecessary risk.

An isolated line that is **local**? Leave it in `HARNESS.md` with a note "waiting for a 2nd
occurrence". An isolated line that is **about the process**? It goes to the ledger as a candidate —
that is where it will meet its second occurrence, coming from another project.

## 2. Classify each line

| The line is… | Destination |
|---|---|
| a **domain** fact — term, enum value, invariant, format | `CONTEXT.md` (if vocabulary) or an **ADR** (if a durable decision passing the three tests) |
| a gap in the **map** — "I could not find where X lives" | a line in `AGENTS.md` (routing, not a rule) |
| missing **tooling** — a smoke command, script, seed, setup doc | create it (a harness improvement) · if it depends on the human (credential, installation), it goes to 🔴 with the command ready |
| **product** disguised as friction | a **behavior**, in the right epic |
| a **hook threshold or behavior** getting in the way | adjust the number/pattern in the hook under `~/.claude/hooks/` and say which changed |
| a **skill rule** that got in the way or was missing | a proposed edit to the skill under `~/.claude/skills/` — **never edit without explicit approval** |
| a **FRICTION pattern** (2+ occurrences) | a new or adjusted rule in a **skill** or **hook** — the most valuable promotion. **Propose and wait** |
| **isolated** FRICTION (1 occurrence) | **stays in the file**, noted "waiting for a 2nd occurrence". Do not discard |
| noise, already resolved, or not corroborated | discard, with a one-line note in the report |

A distinction that does not bend: **a harness improvement ≠ a behavior.** The harness improves the
machine that delivers; a behavior improves what gets delivered. If the line changes what the client
sees, it is a behavior.

## 3. Propose — numbered, self-contained

```
HARNESS.md · 11 lines · 3 repetitions · ledger: 2 applied, 1 candidate

⚙️ GLOBAL CHANGE PROPOSED — affects all projects (approve separately)
0. Pattern: 3 behaviors failed on the 1st attempt, always from the same kind of
   ambiguity — the "Then" stated the ACTION but not the resulting STATE.
   (+ ledger candidate: same pattern seen in <other-project> on 2026-07-30
    → this is CROSS-PROJECT, promote now)
   File:   ~/.claude/skills/breakdown/SKILL.md, section "One behavior → one stub file"
   BEFORE: "Complete scenarios: happy path + every edge the epic implies"
   AFTER:  "Complete scenarios: happy path + every edge. Every `Then` names the
            resulting OBSERVABLE STATE, not just the action — 'continues' without
            saying what gets recorded is ambiguous and costs an attempt"
   Approve? If yes, I record it under Applied and leave the commit ready.

LOCAL — REPEATED (handle first)
1. Date format not documented (08-12 and 08-19)
   → CONFIRMED in the schema: comes as DD/MM/YYYY
   → CONTEXT.md: term "Publication date" + the format
2. Missing smoke command (3 occurrences) → create bin/smoke.sh · ~15 lines

PROMOTE (3)
3. 5th status value "suspended" → CONFIRMED in the code → CONTEXT.md
4. ...

🔴 FOR YOU (1)
9. Read access to the staging database — the agent cannot confirm the format without it

DISCARD (2)
10. "wanted a better debugger" — not actionable
11. Already resolved by ADR-0005
```

The user answers `1-8 apply, 9 later, 10-11 discard`.

## 4. Apply and clean up

- Write the approved promotions to their proper owners.
- **Remove from `HARNESS.md` every line promoted or discarded.** What stays is what is waiting on a
  decision — and it stays visible in the next triage.
- **Update the ledger** (`~/.claude/harness/LEDGER.md`) every time: a global approved → *Applied* ·
  a global rejected → *Rejected* · process friction seen once → *Candidates* (with project and
  date). **The ledger is the cross-project memory — without it the next triage, in another project,
  is blind.**
- Edited a hook or skill? Say which file and what changed, in one line, and leave the commit ready
  if `~/.claude/` is under git.
- Report: how many local promotions, how many global changes applied, how many discarded, how many
  waiting for a 2nd occurrence, and the next suggested cadence.

## Cadence

Weekly, or when the file passes ~15 lines, or when the same friction appears twice. **It takes ~5
minutes** — the trade that turns task management into harness engineering.
