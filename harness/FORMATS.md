# Canonical formats

Single owner of every format in this workflow. Skills point here and **never redefine a
format** (one fact, one owner). If a format must change, it changes here — in one place.

---

## 1. Vocabulary

Three levels, three words. No others are allowed.

| Level | Definition | Scale |
|---|---|---|
| **Project** | one client, one contract | 1 repo · months |
| **Epic** | one complete cycle of value: something the user could not do before and now can | 3–8 per project · days to weeks · 1 PR |
| **Behavior** | a visible action, in a specific context, with an observable result | 4–12 per epic · hours · 1 branch · 1 file |

**Dead words — never use:** ~~slice~~ ~~task~~ ~~PRD~~ ~~issue~~ ~~story~~.

**Nothing exists below a behavior.** Technical work exists, but it lives in the Technical
Plan inside the behavior file, written at execution time. The user never manages anything
below a behavior.

Quick tests:
- **Is it a behavior?** You can demo it to the client on screen. Has "and" between two user
  actions → it is two. No observable result of its own → it is a step, and belongs in some
  other behavior's Technical Plan.
- **Too big:** >6 scenarios · "and" in the title · touches more than one screen/endpoint/command.
- **Too small:** no observable result of its own.
- **New epic or new behavior?** A capability the user did not have → new epic. A new visible
  action inside an existing capability → behavior in the existing epic.
  Rule of thumb: fits in one PR and you would present it in a meeting as "look what shipped"? → epic.

### 1.1 Decomposing a monolithic system (pipeline, engine, agent) — behaviors are PATHS

The most common case: the system is not a site of independent pages, it is a **coupled
pipeline** (fetch → parse → judge → dedupe → persist → notify). The naive decomposition
splits by **stage**, and it is wrong:

```
❌ HORIZONTAL, by stage              ✅ VERTICAL, by path
   "the crawler fetches pages"          every behavior crosses the WHOLE pipeline
   "the parser extracts links"          001  a new source is recorded with URL and date
   "the classifier evaluates"           002  page is down: continue with the rest, log the failure
   "it saves to the database"           003  source already registered: do not duplicate
                                        004  page is not a source: discard with the reason
                                        005  operator sees how many new sources came in
```

Why horizontal fails: no stage is **demonstrable to the client**, none has an observable
result of its own (fails the behavior test), and all depend in a chain → waves of one item
each, which is the signature of a bad graph.

Why vertical works — and this answers the fear that behaviors will end up disconnected:
**each behavior crosses the entire system, so every behavior is an integration test by
construction.** Disconnection comes from splitting by stage; splitting by path guarantees
integration.

**Typical graph shape in a pipeline**: one **heavy** first behavior (the happy path, which
builds the whole route) plus a **fan of edges** that depend only on it.

```
001 happy path       depends_on: []          wave 1 → 001
002 edge             depends_on: [001]       wave 2 → 002, 003, 004, 005  (real parallelism:
003 edge             depends_on: [001]                each touches a different edge
004 edge             depends_on: [001]                of a pipeline that ALREADY exists)
005 output/report    depends_on: [001]
```

A wave with a single item here is **not** a bad-graph signal — as long as wave 2 has several.

**Escape valves, in this order:**
1. Small epic → **3 behaviors, not 12.** Never invent behaviors to fill a quota.
2. Genuinely indivisible → **1 behavior, and granularity drops to the scenarios.** A behavior
   with 6 scenarios is verified 6 times; verify runs scenario by scenario, so nothing is lost.
   *(A happy path with more than ~6 scenarios usually means the edges inside it are already
   behaviors trying to get out.)*

**Two axes that must not be confused:** a behavior is a unit of **specification and
verification**; a module/slice is a unit of **code organization**. A pipeline can have 6
behaviors and zero modularity in code. **Behaviors do not create folders** — the
decomposition is of the spec. Legacy code stays where it is (`PRINCIPLES.md §2`); the spec
points at where it lives.

---

## 2. Project layout

```
<project>/
├── AGENTS.md                     the map (~40 lines, routing only) · CLAUDE.md = "@AGENTS.md"
├── PLAN.md                       Contract + 🔴 + epic index (§3)
├── CONTEXT.md                    domain glossary (format: grill-with-docs/CONTEXT-FORMAT.md)
├── HARNESS.md                    agent telemetry (§12)
├── docs/adr/                     durable decisions (format: grill-with-docs/ADR-FORMAT.md)
├── specs/
│   └── <epic>/
│       ├── EPIC.md               the cycle of value (§4)
│       ├── prototype/            only when the epic came from a prototype — disposable
│       └── behaviors/
│           └── NNN-<slug>.md     one file per behavior (§5)
├── evals/
│   ├── rubrics/<capability>.md   what counts as correct (§9)
│   ├── runs/                     battery history (§10)
│   └── target.md                 adapter: how to run one input (§11)
└── intake/
    ├── meetings/YYYY-MM-DD-<slug>.md    full transcript, dated, never edited
    ├── messages/YYYY-MM-DD-<slug>.md    Discord, WhatsApp, email, screenshot
    └── references/                       contract, PDF, Figma, brand guide
```

Everything is created **lazily** — when there is real content. An empty folder is worse than
a missing one: it looks filled in.

---

## 3. PLAN.md

The only file the **user** reads. Three sections, in this order:

```markdown
# Plan — <project>

## Contract
Outcome: <one sentence — how the client knows the project succeeded>
Project deadline: <ISO date, or "none set">
Invariant rules: <what the system must never do or violate>
Out of scope: <explicit. the field that protects the project most>

## 🔴 Blocked on you
- <each line: situation + what to decide or run + your recommendation. Decidable FROM HERE,
  without opening anything. Credential · product decision · ready-to-run command ·
  pending blind review>

## Epics
1. [x] <slug> — <one sentence> (closed YYYY-MM-DD)
2. [-] <slug> — <one sentence> · specs/<slug>/
3. [ ] <slug> — <one sentence>
4. [ ] <slug> — <one sentence>
```

Index rules:
- **A future epic is a name plus ONE line. It is never specified before its turn** —
  late specification: order is planned early, content at the moment of work.
- Status: `[ ]` not started · `[-]` in progress · `[x]` closed (ISO date).
- **One `[-]` epic at a time** (default; an exception is a conscious decision by the user).
- Dead epic: move to a `### Dead` subsection with date and reason. Never delete.

---

## 4. EPIC.md — `specs/<epic>/EPIC.md`

**Functional language only**: what users do and see. Zero technical terms (no tables,
endpoints, libraries — unless the product IS an API).

```markdown
# Epic: <name>

## Objective
<one paragraph: what problem this solves and for whom. Someone with no technical background
understands it completely.>

## Current state
<what exists today that this touches or changes. "Nothing — new capability" is a valid answer.>

## Behaviors
<the complete list of unit behaviors. Each item: context + trigger + outcome.>
1. In <context>, when <trigger>, then <outcome>.
2. ...

## Out of scope
<behaviors deliberately NOT included, so nobody — human or AI — invents them.>

## Open decisions
<whatever the interview or prototype left unresolved. MUST be empty (or explicitly deferred
by the user) before /breakdown runs.>

## Source
- [ ] Interview on <YYYY-MM-DD>
- [ ] Prototype at <path> on <YYYY-MM-DD>  (the prototype stays as visual reference;
      the epic text must stand on its own)
```

---

## 5. Behavior — `specs/<epic>/behaviors/NNN-<slug>.md`

The frontmatter is **machine-readable state** — the contract between agent, skills and
(future) orchestrator.

```markdown
---
id: "004"                     # sequential, zero-padded, unique within the epic
epic: <epic-slug>
title: <behavior name, action-first>
depends_on: ["001"]           # MINIMAL. a false dependency destroys parallelism
status: pending               # pending | in_progress | done | failed | blocked | cancelled
attempts: 0                   # incremented by verify on failure · max 3
blocked_by: ""                # who or what unblocks — only when blocked
cancelled: ""                 # "YYYY-MM-DD — reason" — only when cancelled
ctx:                          # the WHY, not the code (plan researches code on its own)
  - intake/meetings/2026-07-18-kickoff.md
  - docs/adr/0003-<slug>.md
  - evals/rubrics/<capability>.md
---

# Behavior: <title>

## Context
<where it happens: screen / endpoint / command / event>

## Trigger
<what the user (or the system) does>

## Outcome
<what observably happens>

## Scenarios
<the CONTRACT. format in §6. happy path + EVERY edge the epic implies>

<!-- ══ everything below is appended by the pipeline — never written at breakdown ══
## Technical Plan       ← /feature phase 1 · deleted and rewritten each attempt
## Verification Report  ← /feature phase 3, on pass
## Failure Report (N)   ← /feature phase 3, on failure · the next attempt's inheritance
## Blind Review Request ← /feature, when the behavior touched a sensitive zone
## Semantic Review      ← /review
-->
```

**A behavior is born as a STUB**: frontmatter + Context/Trigger/Outcome + Scenarios. Nothing
else. The Technical Plan is written at execution time, because by the time behavior 32 runs,
behaviors 1–31 have already changed the codebase.

---

## 6. Scenarios

Every scenario is **one concrete, verifiable case**, with its type declared in the title:

```markdown
### Scenario: <name> [deterministic]
- Given:  <initial state>
- When:   <action>
- Then:   <exact observable result — message, status, file, record>

### Scenario: <name> [semantic · rubric <capability>]
- Given:  <state/input>
- When:   <action>
- Then:   (judged) <claim the judge evaluates against the rubric>
```

Rules:
- **Every scenario must be verifiable — by a program OR by a judge against a versioned
  rubric. "Vibes" are forbidden.** An unverifiable scenario gets renegotiated, not skipped.
- `[deterministic]` → becomes one behavior test (black box: input → observable output).
  Zero cost per run.
- `[semantic · rubric X]` → goes to the judge model. **Every semantic scenario costs money on
  every future run** — if it can be made deterministic (field, numeric range, presence),
  make it deterministic.
- The field that is almost always missing: a **numeric range** (score, confidence, cost,
  count). Without it, a prompt change can keep every decision correct while degrading the
  system, and no test turns red.
- Data extraction: **assert null-when-absent** — an extractor that guesses a plausible value
  passes any schema test and is the most dangerous failure of its kind.
- Conversational systems: the case is a **turn script**, not a single call — `Given` describes
  the conversation so far, and the target (§11) must be able to drive a sequence.
- A failure always **names the scenario** ("scenario 'empty email' should have shown X and did not").

### 6.1 What does NOT fit in a scenario — and where each thing lives

`Given/When/Then` was chosen because it has **test shape** (setup → action → assert) and
**forces observability**. But it describes **one case**, and three things are not cases.
Forcing them into scenarios produces bad specs — each has its own owner:

| Not a scenario | Why not | Where it lives |
|---|---|---|
| **Invariant** — *"the balance never goes negative, regardless of operation order"* | a universal quantifier, not a case | the **`invariants`** field of the Technical Plan → becomes a **property test**. A project-wide business invariant also goes in the **Contract** |
| **Systemic non-functional** — *"handles 10k emails/day"*, *"3 concurrent users do not corrupt the queue"* | a property of the system under load, not an interaction | **Contract** in `PLAN.md` (as a constraint). If it requires building, it becomes its **own behavior** with a load scenario; if it is just an operational ceiling, an ADR plus a dedicated test |
| **Tabular rule** — *"if A and B but not C → X"*, 12 combinations | 12 scenarios lose the structure and nobody sees what is missing | the **table** goes to `CONTEXT.md` or an **ADR** (domain knowledge, one owner). Scenarios **sample** the table: happy path plus the edges that matter. The Technical Plan covers the rest with a **table-driven test** over the whole table |

**Per-request non-functional is the exception and DOES become a scenario**, because it is
observable in a single case: *"Then: the response arrives in under 2s"* · *"Then: the call
cost stays below X"*. Same family as the numeric range — and among the highest-value asserts.

Rule of thumb: **if you need the words "always", "never" or "any" in the `Then`, it is not a
scenario — it is an invariant.** A scenario speaks about one concrete case.

---

## 7. States and transitions

| State | Means | Rules |
|---|---|---|
| `pending` | queued | runnable only when every `depends_on` is `done` |
| `in_progress` | an agent picked it up | set the instant execution begins |
| `done` | **verify's verdict, never the executor's** | every scenario with evidence + mutation audit + full suite green |
| `failed` | 3 hypotheses failed | **stop.** The problem is upstream. The 3 Failure Reports go to the user with a recommendation of what to renegotiate |
| `blocked` | an **external** dependency (credential, approval, client decision) | `blocked_by` filled + a line in 🔴. **Never disguised as failed** |
| `cancelled` | dead | date and reason required. **Never deleted.** If it was already merged → generate a **removal behavior**, with its own scenarios ("on screen X, option Y no longer exists") |

A `done` behavior is **never edited**. Something already delivered changed → **new** behavior.
One behavior implemented OR one behavior modified — never rewrite history.

---

## 8. Pipeline reports (sections of the behavior file)

**Failure Report** — written by verify on failure; it is the next attempt's inheritance:

```markdown
## Failure Report (attempt N)
- **Hypothesis**: the approach this implementation took (one paragraph)
- **Failure**: which scenarios failed and exactly how (with evidence)
- **Learning**: the best diagnosis of WHY the approach cannot work
- **Do not retry**: the specific dead end the next attempt is forbidden to try
```

**Verification Report** — written by verify on pass:

```markdown
## Verification Report
| Scenario | Verdict | Evidence |
<one row per scenario — test output, response body, command, judge verdict with citation>
- Mutation audit: <the bug injected · the test that caught it · reverted>
- Full suite: <result>
```

**Semantic Review** — written by /review: per module, what it does now + drift vs the plan's
contract + findings by severity + verdict `MERGE | FIX FIRST | RE-PLAN`.

**Blind Review Request** — when the behavior touched **money, persisted data or auth**:
the problem + what changed **at the behavior level** (FORBIDDEN to name files or functions —
the reviewer must locate it alone; if they cannot, that is already a finding) + observable
acceptance + a ready-to-paste prompt for an independent session. A line in 🔴.

---

## 9. Rubric — `evals/rubrics/<capability>.md`

What counts as correct, in **business language**. This is the judge's criterion.

```markdown
# Rubric — <capability> · v1 · validated by <who> on <YYYY-MM-DD>

## What the system decides
<one sentence>

## Correct means
- <observable criterion, in language the client confirms>

## Incorrect means — the failure classes
- **<class name>**: <description> · <why it matters to the business>

## Outside this judgment
<what this rubric does NOT evaluate — keeps the judge from failing something it does not own>

## Judged examples (seed)
<client judgments captured before behaviors existed — /breakdown converts them into
scenarios and removes them from here. Each one: summarized input · verdict · who judged · date>
```

- **Versioned in the header.** Rubric changed → version bumps → scores across versions are
  **not comparable** (and the ratchet does not apply to that delta).
- **Validated by the client**, not by the developer. No validation → `[??: validate with client]`
  in the header + a line in 🔴.
- When the client disagrees with a system judgment, the question is:
  **is the rubric wrong, or did the system disobey the rubric?** Two bugs, two fixes.

---

## 10. Runs — `evals/runs/YYYY-MM-DD-<commit>.json`

```json
{
  "date": "2026-08-10",
  "commit": "a1b2c3d",
  "scope": "project | epic:<slug>",
  "rubrics": { "classification": "v2" },
  "runner": "independent-subagent | headless | session",
  "score": { "total": 36, "passed": 34, "failed": 1, "inconclusive": 1, "regression": 0 },
  "scenarios": [
    { "behavior": "triage/004", "scenario": "justification is grounded",
      "verdict": "passed | failed | inconclusive", "evidence": "<citation>" }
  ]
}
```

**Ratchet:** passed in the previous run → failed now = **regression, and it blocks** (not a
warning). Accepted only with an explicit record: an ADR stating the trade was deliberate, or
a rubric that changed version (then it is a new criterion, not a regression).

---

## 11. `evals/target.md` — the adapter

The only project-specific part of the eval layer:

```markdown
# Target — <what is under test>
Command: <how to pass ONE input through the system and get the output>
Input: <accepted format>
Output: <returned format + which fields matter>
Cost per case: <tokens/calls/time>
Prerequisite: <credential, service up, seed>
```

If the output has **no structure** (free text), everything becomes semantic and the battery
gets expensive for no reason — structuring the output becomes a priority behavior.

---

## 12. HARNESS.md — agent telemetry

A **candidate channel, not a source of truth** — the agent writes, the user reads (weekly)
and fixes the harness. **Never read as task context; never self-feeding.**

```markdown
## MISTAKES
- YYYY-MM-DD · <epic/id> · I got X wrong because <what the environment failed to tell me>
## LEARNINGS
- YYYY-MM-DD · <fact about the system that was written down nowhere>
## DESIRES
- YYYY-MM-DD · I wanted <command/doc/route> and it did not exist
## FRICTION
- YYYY-MM-DD · <epic/id> · <what the process cost extra, and what caused it>
```

If the agent had to ask something a file should have answered → that is a DESIRE. Record it
**and** ask.

**One-way by design:** the agent **writes** on its own during work; the agent **never reads**
this file as task context. If it did, it would treat its own guess as established project
fact — compounding error. The consumer is the **`/harness`** skill, which corroborates each
line, proposes promotions (glossary · ADR · map · behavior · hook tweak · tooling) and
**removes what was promoted**. It is a queue, not an archive.

**`FRICTION` is process cost, not an environment gap** — that is what separates it from
`MISTAKES`. It holds **efficiency** facts, and the skills write them, not the user:

| Who writes | When | Example line |
|---|---|---|
| `/feature` | behavior consumed **2+ attempts** | `invoices/004 · 3 attempts · scenario "source offline" was ambiguous: "continues" did not say whether it logs or ignores` |
| `/feature` | **mutation audit** failed | `invoices/007 · tests passed with an injected bug — they asserted the return value, not the effect` |
| `/feature` | rewrote the **same module** a recent behavior already touched | `3rd behavior touching the normalizer — likely a missing abstraction` |
| `/feature` | the **reuse gate** found nothing and the code came out large | `wrote 80 lines of date parsing; searched for a library and found none — re-check` |
| `/eval` | **inconclusive** from a vague rubric or a badly written scenario | `rubric classification · 4 inconclusives on the same criterion — "grounded" is not defined` |
| `/eval` | judge **disagreeing with itself** across runs on the same case | `case 012 flipped passed/failed across 3 runs with no code change` |

**Why separate:** without this channel, every Failure Report dies inside its own behavior
file and nobody sees the **pattern**. "3 of the last 5 behaviors failed on the first attempt"
is a **specification** signal, not an execution one — and it is invisible when looking at one
behavior at a time. It is what keeps the framework from only producing work without ever
asking whether it is producing well.

---

## 13. Conventions

- **ISO dates** (`YYYY-MM-DD`) in every chronological record. `DD/MM` is a bug, not a style.
- **Branches**: `wf/<epic>` (epic branch) · `wf/<epic>--<id>` (behavior branch; `--` avoids a
  ref-hierarchy clash with `wf/<epic>`).
- **Commits**: `feat(<epic>/<id>): <behavior title>` · planning state: `chore(wf): ...`.
- **One fact, one owner.** If two files can answer the same question, one of them will lie.
- **Secrets and client data never in git**: `.env*`, `intake/` and similar go in `.gitignore`
  from the first commit, default-deny.
