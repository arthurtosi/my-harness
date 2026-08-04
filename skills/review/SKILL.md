---
name: review
description: Semantic review of an epic (or a single behavior) before merging to main — renarrates the change through the architecture instead of dumping a diff, compares the implemented contract against the planned one, runs the abstract-on-repetition pass, and closes with a MERGE, FIX FIRST or RE-PLAN verdict. Use when the user says "review", "review the epic", "close the epic", "can we merge?", or when every behavior in an epic is done. Requires a fresh /eval run when the epic has semantic scenarios.
---

# Semantic review

A raw diff across N files is unreadable at review time. This review **renarrates the change
through the architecture**: behavior → modules → what each module does now. The reader reads
meaning, not line noise.

**Mandatory framing, start to finish: you are reviewing code written by ANOTHER engineer you have
never met.** In the training corpus, good review is always someone else's — the framing is what
sharpens the critique.

## 0. Gates

- Scope: one behavior (`wf/<epic>--<id>`) or — the normal case — the **whole epic**
  (`wf/<epic>`, all behaviors `done`).
- Epic with `[semantic]` scenarios: require a **fresh** `/eval` run in `evals/runs/` (same commit
  as, or later than, the last merge). None there? **Run `/eval` first** — reviewing without the
  battery means approving the semantic half blind.
- A pending blind review in 🔴 (sensitive zone)? The epic does not close before it is addressed.

## 1. Renarration (per behavior touched)

For each module in the diff:

- **Module** (path) — new or modified.
- **What it does now**, in 1–2 sentences of behavior language.
- **Implemented contract vs the Technical Plan's contract** — any drift gets flagged (silent
  drift is how spec and code diverge without anyone deciding).
- **Notable lines**: only the genuinely important ones, quoted with context — never the whole diff.

## 2. Critical pass — in order of severity

1. **Spec drift**: implemented what the scenarios do not ask for · asked for and missing.
2. **Security**: injection, authz hole, secret, insecure default, input boundary.
3. **Codebase-as-prompt damage**: a duplicated pattern that should reuse an existing abstraction ·
   a NEW abstraction created for a single use (premature) · code future generations will imitate
   badly. *Every merged line becomes context for every future generation.*
4. **Test honesty**: a mock hiding the hard part · a test asserting an implementation detail · a
   scenario with no corresponding test.

## 3. Verdict

- **MERGE** — ready.
- **FIX FIRST** — with the ordered list of fixes. Fixes done → re-review the delta.
- **RE-PLAN** — the approach itself is wrong: it goes back through the failure protocol (Failure
  Report + reset), **not** through patches on top.

## 4. Abstract on repetition — this pass exists only here

This pass **does not fit in `/feature`**: there the agent only sees its own diff. It requires
looking at the whole epic, with the behaviors already merged, and this is the only moment that
happens. Precondition: **a green suite.** Without it, simplifying is gambling, not refactoring.

*(Shrinking the diff already ran inside each `/feature`. Do not repeat it here.)*

1. **Find the same pattern written 2+ times** across the epic's behaviors — repetition of
   **structure**, not superficial text similarity. LLMs repeat patterns instead of abstracting;
   this pass is the antidote.
2. For each repetition, **propose ONE abstraction**: name, contract, where it lives (shared
   layer), and the call sites it replaces. **Justify it with the concrete occurrences** — an
   abstraction with a single caller is premature optimization and **must not be created**.
3. Approved: apply it, replacing **every** call site, and run the **full suite** — this is the one
   moment in the flow where crossing a behavior boundary is expected.
4. Nothing repeated 2+ times? **Say so and skip.** Do not invent an abstraction to justify the pass.
5. If the repetition suggests **an abstraction was missing from the start**, record it in
   `HARNESS.md` (FRICTION) — it is a signal about the decomposition, and `/harness` triage
   aggregates it with the others.

## 5. Close

1. Append `## Semantic Review` to the behavior file (behavior scope) or `specs/<epic>/REVIEW.md`
   (epic scope), including the result of the abstraction pass.
2. The verdict to the user in a short, self-contained message.
3. **MERGE on the complete epic**: one PR per epic (a single behavior never becomes a PR — that is
   noise). Leave the command ready; **the human merges to main**. After the merge: the epic
   becomes `[x]` in the `PLAN.md` index, with the date.
