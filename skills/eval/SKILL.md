---
name: eval
description: Runs the project's semantic battery — sweeps every [semantic] scenario across all behaviors, generates the judge prompt from the rubrics (never hand-written), executes it in an independent-context agent, compares against the previous run (regression ratchet) and turns failures into behaviors. Use when the user says "/eval", "run the battery", "score", "how are the semantic tests", when closing an epic, or before showing or delivering anything to the client. Also for scheduling the nightly battery.
---

# Run the semantic battery

Formats (rubric, run, target): `~/.claude/harness/FORMATS.md §9–11`. The deterministic suite runs
inside each behavior's verify; **this battery is the authoritative semantic pass** — the smoke
that `/feature` runs in-session carries author bias, this one must not.

**The judge prompt is GENERATED — from the rubric and the scenarios — never written or edited by
hand.** An authored prompt makes every run use slightly different criteria: the score stops being
comparable and the ratchet loses its meaning. If you catch yourself tweaking the text so a
scenario passes, stop — what changes is the rubric (with the client) or the system (a new behavior).

## 1. Scope and cost — before spending

- Collect the `[semantic · rubric X]` scenarios from **all behaviors** in scope (`--epic <slug>`
  or the whole project; default: the project). One grep over `specs/*/behaviors/*.md` does it.
- No `evals/target.md`? Create it with the user now (FORMATS §11) — without the adapter there is
  no way to run an input. If the system's output has no structure, say so: everything becomes
  semantic and the battery gets needlessly expensive — structuring the output is a priority behavior.
- **Estimate the cost first**: number of scenarios × cost per case from `target.md`. If the cost is
  material, running it is the user's trigger (same yardstick as a deploy).

## 2. Run the cheap part first

The project's full deterministic suite (test runner — seconds, zero tokens). A behavior with a
broken deterministic scenario has its semantic ones **skipped and marked**: judging the semantics
of a structurally wrong output is burning money.

## 3. Generate the judge and run it — in INDEPENDENT context

Assemble the prompt per rubric:

1. the **entire current rubric** (with its version — it goes into the run record);
2. per scenario: the input, the **output the system produced**, and the `Then (judged)` as the question;
3. a verdict **per scenario**: passed / failed / inconclusive, **with a citation of the excerpt of
   the output** that supports it — no citation means inconclusive, never "passed";
4. the judge's rules inside the generated prompt: judge only what the rubric governs (anything
   under "Outside this judgment" does not fail it) · do not suggest fixes, do not rewrite the
   output · structured, parseable response.

**Independence is mandatory**: the judge is never the session that implemented the code nor the one
that wrote the scenarios. In order of preference: a subagent with clean context (Agent tool) → a
dedicated headless session (`claude -p`) → at minimum, a fresh session. Record which runner was
used in the run file.

## 4. Ratchet — the comparison that gives the score meaning

Against the most recent run in `evals/runs/`:

| before → now | classification |
|---|---|
| failed → passed | fixed |
| passed → passed | stable |
| failed → failed | known (not news) |
| **passed → failed** | **REGRESSION — blocks the epic.** Not a warning |
| did not exist → anything | new |

A regression is accepted only with an explicit record: an ADR stating the trade was deliberate, or
a **rubric that changed version** between runs — in which case the score is not comparable and the
ratchet does not apply to that delta (say so loudly in the report).

## 5. Close the loop

- Write `evals/runs/YYYY-MM-DD-<commit>.json` (FORMATS §10).
- **Every failure becomes a behavior** (or a scenario on an existing behavior reopened as a new one
  — `done` is never edited), with the scenario itself as the contract. A regression goes **to the
  top of the queue**, not the backlog.
- Inconclusives → 🔴 (they need human judgment).
- The system obeyed the rubric and the result is still bad? **That is not a behavior — the rubric is
  wrong**: a conversation with the client, in 🔴.
- **Record FRICTION in `HARNESS.md`** (`FORMATS §12`) when the problem belongs to the **eval layer**,
  not the product:
  - **2+ inconclusives on the same criterion** → that rubric criterion is vague. Name which word is
    undefined
  - **a case flipping** passed/failed across runs **with no code change** → a badly written scenario
    or a subjective criterion; the judge is not being determined by the rubric
  - **a semantic scenario that could have been deterministic** → it should have been deterministic at
    `/breakdown`; it costs tokens on every future run for nothing
  - **cost per run disproportionate** to the signal the battery returns
  This is what makes the rubric and the scenarios **improve with use** instead of merely accumulating.

## 6. Report — regression first, score second

```
Battery · <scope> · <N> scenarios · rubrics: classification@v2 · commit <hash> · runner <which>

⚠️ 1 REGRESSION — <epic>/004 "justification is grounded" passed on 2026-08-02
   → <what the evidence shows> → new behavior <id> at the top of the queue
<M> passed · <F> failed (known: <K>) · <I> inconclusive → 🔴
Fixed since the last run: <C>
```

## When delivering to the client

A client-facing report separates **guarantee** from **premise**:
- **guarantee** — a rule in code, tested: *"without a valid source the system does not classify"*;
- **premise** — prompt-guided behavior, measured and never 100%: *"it is instructed to cite the
  excerpt supporting its decision — N of M scenarios judged by your team"*.

Never state model behavior categorically (*"the AI does not make things up"* is a promise the model
will break in front of the client). The measured number, with the failing cases named, is
verifiable — and it is what sustains maintenance.
