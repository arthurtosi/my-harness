---
name: feature
description: Runs ONE behavior end to end through the plan → execute → verify protocol, with a reset on failure (max 3 attempts) and a decision packet at the end. With no argument it picks the next runnable behavior in the graph. Use when the user says "/feature", "next behavior", "let's go", "continue the project", "run 004", or sends a loose change request in a repo with the harness — in that case the request becomes a behavior before it becomes code. No change without a behavior.
---

# Run one behavior

One behavior, one branch, one decision packet. Formats (frontmatter, scenarios, reports):
`~/.claude/harness/FORMATS.md` — do not redefine any of it here. How to communicate with the
user: `~/.claude/harness/PROFILE.md`.

**Selection**: an argument means that behavior. No argument means the next runnable one in wave
order: lowest `id` with `status: pending` whose `depends_on` are all `done`. `blocked` and
`failed` are never selected (`failed` re-enters only by human decision).

**A loose request from the user** (no existing behavior): write the behavior first — a stub with
scenarios, in the right epic (a new capability → ask whether it opens an epic) — and only then
execute. No change without a behavior; that is what keeps the plan true.

## Gates (before anything)

1. **Git**: does `git rev-parse HEAD` work? If not — **STOP**. Assemble a default-deny
   `.gitignore` (`.env*`, `intake/`, client data), leave the commands ready for the user to run,
   and record it in 🔴. Without a commit there is no reset, and without reset the protocol is theater.
2. **Branch**: ensure `wf/<epic>` exists (created from main if needed). Create
   `wf/<epic>--<id>` from `wf/<epic>` and work **on it**.
3. Set `status: in_progress` in the frontmatter — the instant you start, not later.

## Phase 0 — Grounding (read little, read right)

1. The Contract at the top of `PLAN.md` (scope, invariants, out of scope).
2. The behavior file, in full.
3. **Its `ctx:` — mandatory reading, never skipped.** Going the wrong direction because you did
   not read the source that governed the behavior is the most expensive error there is. No `ctx:`
   means under-specified: fill in the pointers (grep the topic across the canon and intake)
   before acting.
4. **Failure Reports from previous attempts**: if they exist, read them. The dead ends described
   under **Do not retry** are FORBIDDEN. Delete the old Technical Plan.

Do not read the whole repository. The context slice is the size of the behavior.

Restate the contract in 3 lines — and nothing more (detailed policy here competes for attention
across the whole job; specific rules are retrieved at the moment of decision):

```
Behavior: <id> — <title>
Scenarios: <N deterministic, M semantic — they are the contract>
Authority: engineering is mine · product/scope/cost is the user's
```

Authority, by default: engineering choices (library, pattern, how to test, keep vs revert) —
**you decide and execute**. Do not hand back "which do you prefer?" about something purely
technical. Escalate only what changes product, scope or cost, or depends on an external fact,
credential or client decision.

## Phase 1 — PLAN (now, against the codebase as it is)

Output: a `## Technical Plan` section in the behavior file. **No code in this phase.**

1. **Ambiguous or unverifiable scenario?** Stop and flag it — do not plan around it.

### The reuse gate — mandatory, and it becomes an artifact in the plan

**The coding paradigm here is: write the least code possible. Code that does not exist has no
bugs, needs no tests, and never becomes a bad prompt for future generations.** Before designing
any new module, exhaust both searches below. **The Technical Plan is not complete without the
`### Reuse` section filled in** — a passive rule becomes a forced artifact: what you write down,
you do not forget.

2. **INTERNAL search — does it already exist in this project?** A function, helper, utility,
   type, pattern. The most common agent error is reimplementing what sits three files away.
   - **With Serena** (`mcp__serena__*`; activate the project if needed): `get_symbols_overview`
     to orient, **`find_symbol` to search by name or concept before creating anything**,
     `find_referencing_symbols` to see who uses what you are about to touch. Symbol navigation
     is cheaper and more precise than reading whole files.
   - **Without Serena**: grep/glob by name, by verb and by signature. It degrades, it does not break.
   - Found something **similar but not identical**? Preference order: **use as is > extend with a
     parameter > extract the common part > write new.** Writing new is the last option and
     requires justification in the plan.
   - Also research the patterns/slices already established for this kind of behavior — the plan
     **imitates, it does not innovate** — and the code of the behaviors in `depends_on`, which is
     your integration surface.

3. **EXTERNAL search — is there a popular library that solves this?** Always, before writing your
   own logic. An LLM only does well what it has seen many times: it has seen thousands of
   examples of the popular library and zero of our code.
   - **Not CERTAIN the library/API is current and maintained? SEARCH THE WEB** — the model's
     memory froze at training time and the ecosystem did not. Never decide a stack from memory.
   - Prefer what is already in the project manifest (`package.json`/`pyproject.toml`) before
     adding a new dependency. A new dependency is a decision with a cost — it only pays off
     against significant custom code.
   - Classic do-not-reinvent cases: dates/timezones, parsing (HTML, CSV, email, URL),
     retry/backoff, schema validation, slugs, money/rounding, cryptography.
     **Never hand-write these.**

**The mandatory plan section** — without it the plan is incomplete:

```markdown
### Reuse — what already exists
- Internal: <symbol/file I will use or extend> · or "nothing applicable: searched for <what>"
- External: <lib + version, and why it> · or "nothing applicable: searched <terms>, web on <date>"
- Rejected: <what I found and did NOT use, with the reason in one line>
- Writing from scratch: <only what is left, and why>
```

If you wrote a significant block of code and the `External` line says "nothing applicable",
**record it in `HARNESS.md` (FRICTION)** — the search may have been shallow, and that is a
pattern worth detecting.

4. **Design the slice**: all new code for this behavior lives together, touching shared code only
   through existing abstractions. **Legacy code stays where it is** — do not restructure someone
   else's code; the spec points at where it actually lives.
5. **Module contracts** (2–5 typically): location · contract (input → output, WHAT, not how) ·
   invariants (what holds always, regardless of input).
6. **Test plan**: one behavior test per deterministic scenario, black box, mocking **only**
   external boundaries (network, clock, third-party API) — never what is under test.
7. **Verification procedure**: exact commands per scenario, executable **without human
   judgment**. A semantic scenario → the judge against the named rubric. A scenario that cannot
   be made executable gets renegotiated NOW, not at verify time.

A real technical fork, with legitimate alternatives, that no ADR governs? **Invoke `grill-me`**,
resolve it in a few questions, decide and move. If the decision passes the three ADR tests (hard
to reverse · surprising without context · a real trade-off), turn it into an ADR at close.
**Product or scope** ambiguity is not a technical fork: `[??]` + 🔴, and continue on what is not
blocked.

## Phase 2 — EXECUTE

1. **Tests first, from the scenarios.** One test per deterministic scenario, asserting exactly
   the Given/When/Then, BEFORE the implementation. **They must be red right now** — a test that
   passes before any implementation exists tests nothing; rewrite it.
2. **Implement per the plan.** Exact contracts and locations; no substituting a library without
   re-planning. **`ponytail` governs this entire phase**: the shortest diff that passes the
   scenarios, reuse before writing, stdlib before a dependency, abstraction only on repetition.
   *(Boundary: grill decides the what, ponytail decides the size — never in the same turn.)*
3. **It works → shrink it. Loop until a pass produces no cut.** Not a single pass: repeat until
   you cannot cut further without breaking a scenario.
   - *"Rewrite this in a simpler version with the same behavior."* Target: fewer lines, less
     indirection, fewer branches, no cleverness. **Prefer deleting to rewriting.**
   - Run the tests after **every** cut. Green → keep the cut. Red → revert **that cut** (never
     adjust a test to keep a cut).
   - Also delete: dead code, unused parameters, comments restating the code, configuration
     nobody sets, defensive handling for a case that cannot happen.
   - Metric: **the line count went down and the suite stayed green.** "Added robustness" is never
     simplification.
   - Every merged line becomes a prompt for every future generation — that is why this pass is
     mandatory, not cosmetic.
4. **Self-critique in the third person** — literally: *"An engineer you have never met wrote the
   following diff. List security problems, spec violations and unnecessary complexity."* Fix what
   you find. (The framing matters: models critique someone else's code far better than "their own".)
5. Commit: `feat(<epic>/<id>): <title>`.

**Hard rules (anti-reward-hacking):**
- Never modify a test to make it pass. A red test means the code is wrong, until the **spec**
  changes by human decision.
- Never mock the module under test or the hard part of the behavior.
- Never mark anything done here — **`done` is verify's verdict, not yours**.
- Do not touch code outside this behavior's slice unless the plan explicitly says so.
- Do not "improve" neighboring code in passing — note it in `HARNESS.md` (DESIRES) and move on.

## Phase 3 — VERIFY (you are verifying someone else's work. Assume nothing; run everything)

In order — cheapest first:

1. **Deterministic scenarios**: run the plan's procedure, scenario by scenario, PASS/FAIL verdict
   **with evidence** (test output, response, command). A procedure that cannot run = FAIL for
   that scenario. No "probably fine".
2. **Semantic scenarios — smoke**: only if the deterministic ones passed (judging the semantics of
   a structurally wrong output is burning money). Generate the judge prompt **from the rubric plus
   the scenario — never hand-written** — and run it. Verdict per line **with the excerpt cited**;
   no citation means inconclusive, not "passed". *This smoke runs in the same session and carries
   author bias: the authoritative, independent pass is `/eval` at epic close. Note that in the report.*
3. **Mutation audit**: at the 1–2 most important points of the diff, inject a deliberate bug
   (flip a condition, drop a validation) and run the tests. **Nothing failed = the tests are
   decoration** → record it as a failure, revert the bug, and the behavior FAILS with instructions
   to fix the tests. Always revert the mutation.
4. **The untouched world**: the project's full suite. This behavior must not have broken anyone
   else's scenario.
5. **Sensitive zone** (money · persisted data · auth): write the `## Blind Review Request` in the
   behavior file (behavior level, **forbidden to name files or functions** — the reviewer locates
   it alone) + a line in 🔴. The epic does not close with a pending blind review.

### PASSED

1. `## Verification Report` in the file (scenario → verdict → evidence table + mutation + suite).
   `status: done`.
2. Merge: `git checkout wf/<epic> && git merge --no-ff wf/<epic>--<id>`, then delete the behavior
   branch.
3. A durable decision made along the way → an ADR (grill-with-docs format). A new term →
   `CONTEXT.md`. Something missing in the environment → `HARNESS.md` (MISTAKES/LEARNINGS/DESIRES).
4. **Record FRICTION in `HARNESS.md` if any of these is true** (the process-efficiency channel —
   `FORMATS §12`; without it the pattern is invisible one behavior at a time):
   - it consumed **2+ attempts** → record what in the spec caused the first failure
   - the **mutation audit** caught weak tests → record what the tests were asserting wrongly
   - you touched a module **another recent behavior also touched** → likely a missing abstraction
   - the reuse gate's `External` line came out empty and you wrote a **significant block of your
     own code** → the search may have been shallow
5. **Decision packet in chat** — and nothing beyond it:

```
**Problem:** <the pain this behavior solves>
**Behavior:** <id> — <title>
**Fix:** <what was implemented and why — the trade-off, if any>
**Proof:** <scenarios X/X with evidence · mutation ok · suite ok>
**Left out:** <assumption made, path not tested — or "nothing">
**Next:** <next id · or "wave closed" · or "epic closed → /eval + /review">
```

6. **Chain into the next runnable behavior only if the user asked for it.** By default, when a
   behavior closes, **propose a fresh session** — state lives entirely in files and a new session
   starts clean (`PROFILE.md`). Stop unconditionally on: epic closed · real blocker (`blocked` +
   🔴) · pending blind review · regression.

### FAILED — reset, do not pile on

Broken code in context contaminates the next attempts — the search stays stuck in the same
basin. So:

1. Write `## Failure Report (attempt N)` — the 4 fields: **Hypothesis · Failure · Learning · Do
   not retry** (FORMATS §8).
2. Preserve the report: `git checkout wf/<epic>` and write the updated behavior file (report +
   incremented `attempts` + Technical Plan deleted) **onto the epic branch**, commit
   `chore(wf): behavior <id> attempt N failed`. Then `git branch -D wf/<epic>--<id>` — **the
   attempt's code dies; only the behavior file survives.**
3. `attempts < 3` → `status: pending` and **END THIS SESSION**: tell the user attempt N failed and
   that the next one must run in a **fresh session** (`/feature <id>`) — this context is
   contaminated and continuing in it repeats the error. (With an orchestrator, the fresh session
   is automatic.)
4. `attempts >= 3` → `status: failed`. **There is no fourth attempt.** Three failed hypotheses
   mean the problem is upstream: an ambiguous scenario, a wrong dependency, or architecture
   fighting the behavior. Summarize the 3 reports for the user and recommend what to renegotiate.
5. **Always record FRICTION in `HARNESS.md`** on failure — naming **the upstream cause**, not the
   code error: ambiguous scenario, incomplete `ctx:`, badly declared dependency, badly designed
   module contract. That record is what makes "3 of the last 5 behaviors failed on the first
   attempt" visible in `/harness` triage — without it, every Failure Report dies inside its own
   file and the pattern never appears.

## Always, before responding

Compaction is automatic and unannounced — never rely on conversation memory. Write: the behavior
frontmatter · the 🔴 in `PLAN.md` if something got blocked · `HARNESS.md` if the environment fell
short. What is not in a file does not exist.
c