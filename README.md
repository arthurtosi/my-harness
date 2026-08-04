# Project Harness

A workflow for running client software projects with coding agents — from the kickoff call to
delivery. Behavior-driven specification, verification that also covers what is *semantic*, and a
process that improves itself.

Ten skills, three hooks, five documents. It lives in `~/.claude/` and applies to every project
you have, present and future. **Nothing is duplicated per project.**

> **Status: early, and being tested in anger.**
> I built this over a few weeks and it has not yet survived a full project end to end. Expect
> breaking changes to file names, formats and skill boundaries. I am publishing it now because the
> reasoning is worth more than the polish — and because the parts that will change are the parts
> real use will tell me about. If you adopt it, pin a commit.

---

## Why I built this

I run about four client AI projects in parallel. I have no engineering manager — I have a
consultant who owns the client relationship and hands me demands that are, by design,
high-level: *"the client wants the emails triaged"*. Turning that into something buildable is my
job, and so is deciding what gets built first.

For a long time my process was: **one enormous chat per project.** It would grow, get compacted,
grow again. When it got too lost I would open a new one and paste a giant prompt asking the agent
to read the whole repository and get oriented — hoping it studied the right things. Then I would
ask for whatever came to mind.

That produced four specific failures, and every piece of this harness exists because of one of them:

- **I forgot what the client said.** A decision from meeting one, gone by meeting four.
- **I changed course without noticing.** The plan I wrote at the start slowly stopped describing
  the project, and by the middle the future tasks no longer made sense and the past ones had
  quietly changed.
- **I had no task management.** I did what came to mind. There was no place that answered "what
  should I do now".
- **I could not verify what I ship.** What I build is AI. Correctness is *semantic* — "did it
  classify this correctly and justify it honestly?" — and no script test answers that. So I tested
  by chatting with the system and eyeballing it. Every judgment I made was thrown away, and the
  next week I judged the same thing again.

There is a fifth failure that shaped the design more than any of the others: **I had already tried
good tools and abandoned them mid-project.** I used interview-style planning skills at the start of
projects, loved them, and then stopped — not out of laziness, but economics. Typing a prompt costs
five seconds; opening the plan costs two minutes. **The cheaper option always wins.** So any
process that depends on me remembering to follow it is already dead.

## What I looked at

I went looking, and I over-collected. In rough order:

- **A teammate's context-management system** — a deep, disciplined markdown structure. I liked the
  idea of a canon of truth per project; I did not like carrying four thousand lines of method whose
  bookkeeping was the human's job.
- **Harness engineering** — the practice of improving agent output by shaping the environment
  around it rather than the prompt. This reframed everything. Two ideas in particular: *give the
  agent a map, not a thousand-page manual*, and *guides steer before the fact, sensors catch after
  it — you need both*. I had neither.
- **Spec-driven development frameworks** — Spec Kit, BMAD, OpenSpec, gstack. All real, all solving
  a version of my problem, none solving the client-facing half.
- **A peer's "second brain"** — a general orchestrator agent routing work to per-project agents. I
  wanted it badly and then talked myself out of it (see [Deliberately left out](#deliberately-left-out)).
- **An internal spec-driven kit my team uses** — and this was the turning point. It is far
  stronger than what I had on execution engineering: behavior as a closed definition, technical
  planning at execution time, a hard reset protocol on failure, mutation auditing, third-person
  review. It also had two blind spots that happen to be my entire job: **no client layer** (no
  contract, no meetings, no reconciliation when the client changes their mind) and **no semantic
  verification** (the word "eval" appears nowhere in it).

Every one of those evaluations is recorded in [`harness/LAYERS.md`](harness/LAYERS.md) with the
**trigger that would reopen the decision** — because the real problem was not choosing, it was
re-choosing every time someone recommended something new.

## Where I landed

Keep my own spine — client contract, meeting reconciliation, semantic verification — and import
the execution engineering wholesale.

The synthesis that made it work is one observation:

> **A deterministic test scenario and an AI eval case are the same object.**
>
> `Given/When/Then` — `Given/When` is the input, and the `Then` is verified either by a test runner
> or by a judge model against a versioned rubric. Same pipeline, same failure protocol, same
> regression ratchet.

That turns the source method's hardest rule — *"a scenario that cannot be verified
programmatically must be renegotiated, not skipped"* — from a wall into a door:

**A scenario must be verifiable — by a program OR by a judge against a versioned rubric. Vibes are
still forbidden.**

The second decision was to make the process survive me. The framework does not ask for discipline:
`/feature` is shorter to type than a prompt, a `SessionStart` hook re-injects the route on its own,
a loose request becomes a behavior before it becomes code, and a fourth hook-like sensor writes
down its own friction so the process gets fixed without me having to notice it was broken.

---

## Quick start

```bash
git clone https://github.com/<your-user>/project-harness.git && cd project-harness
claude
```

Then say: **"install this harness, follow INSTALL.md"**.

The agent copies the skills, hooks and harness documents into `~/.claude/`, **merges** the hook
block into your `settings.json` (never overwrites — it shows you the before/after), and asks you
four questions to fill in `harness/PROFILE.md`. Every collision with a file you already have is
reported and you decide.

> **A note on this repository's layout.** The repo root *is* a working `~/.claude` — that is how it
> stays honest: there is one copy of every file, the one actually in use, so nothing can drift
> between "what is published" and "what runs". A default-deny `.gitignore` publishes only the 22
> files that make up the harness; conversation transcripts, credentials, personal settings and
> third-party skills are excluded by construction. You clone it anywhere and install from it.

Then, in any project:

```bash
cd <your-project> && git init && claude
```

```
/init-project        # once per project — hand it the contract, the kickoff transcript, whatever you have
/epic                # specify the next cycle of value
/breakdown           # epic → behaviors + dependency graph
/feature             # the daily loop
```

**Version-control `~/.claude/` before you start.** You are about to let a skill propose edits to
your own framework; do not do that without a rollback.

## The vocabulary

Three levels, three words. Nothing else is allowed, and this matters more than it looks —
imprecise vocabulary here contaminates everything below it.

| Level | Definition | Scale |
|---|---|---|
| **Project** | one client, one contract | 1 repo · months |
| **Epic** | one complete cycle of value: something the user could not do before and now can | 3–8 per project · 1 PR |
| **Behavior** | a visible action, in a specific context, with an observable result | 4–12 per epic · 1 branch · 1 file |

**Nothing exists below a behavior.** Technical work lives in the Technical Plan inside the behavior
file, written at execution time by the agent. The human never manages anything below a behavior —
that is the whole point.

The test that settles arguments: **a behavior is something you can demo to the client on screen.**
"Create the sources table" is not a behavior; it is a step, and it belongs in some behavior's
Technical Plan.

## The loop

```
                              YOU
        ┌──────────────────────┼──────────────────────┐
  /init-project             /intake                 /epic
   once per project    transcript · screenshot    per cycle of value
        │                  · email · contract         │
        ▼                      │                      ▼
   Contract            numbered diff              EPIC.md
   glossary   ◄──────  new · changed · dead      functional
   epic index          scenario · ⚠ contradiction     │
   rubric v1                   │                      ▼
        │              you approve in batch      /breakdown
        │                      │                      │
        │                      └──► mutates ───►  behaviors + scenarios
        │                           the graph      + depends_on
        │                                              │
        │                                   waves: independent runs together
        │                                              ▼
        │                                  ┌────────────────────────┐
        │                                  │  /feature              │
        │                                  │  plan → execute →      │◄─┐
        │                                  │  verify                │  │ failed
        │                                  └──────┬─────────────────┘  │ (max 3)
        │                                         │ passed             │
        │                                         ▼                    │
        │                                 merge into the epic branch ──┘
        │                                         │
        │                          every behavior done
        │                                         ▼
        │                              /eval ──✖ regression blocks
        │                                         ▼
        │                              /review → MERGE | FIX | RE-PLAN
        │                                         │
        └───────────── 🔴 ◄───────────────────────┘
          blocked on you           one PR per epic
                                             │
                                   /harness ◄── HARNESS.md
                                   weekly: friction becomes improvement
```

**You appear in five places**: answering the interview · approving the input diff · clearing the 🔴
panel · reading the six-line decision packets · approving the PR. Never following code line by line.

## The ten skills

| Skill | When | What it returns |
|---|---|---|
| **`/init-project`** | once per project — new or already in flight | Contract, glossary, map, epic index, rubric v1, default-deny `.gitignore` |
| **`/epic`** | specify the next cycle of value | `EPIC.md` in functional language. Forks between an **interview** (business rules) and a **disposable prototype** (interaction) |
| **`/breakdown`** | approved epic, no open decisions | behavior stubs with complete scenarios, a minimal dependency graph, and the wave table |
| **`/feature`** | **the daily loop** | plan → execute → verify, with a hard reset on failure. A six-line decision packet |
| **`/intake`** | anything arrives from outside | archives it under `intake/` on its own, then a numbered diff over the behavior graph |
| **`/review`** | every behavior in the epic is `done` | renarration per module, drift against the plan's contract, the abstract-on-repetition pass, and a verdict |
| **`/eval`** | closing an epic · nightly · before delivery | the semantic battery in an independent judge, with a regression ratchet |
| **`/harness`** | weekly, ~5 minutes | triages the friction the agent recorded into local fixes and **global framework changes** |
| **`grill-with-docs`** | project start, reopening a decision | *external* — see credits |
| **`grill-me`** | a technical fork no ADR governs | *external* — see credits |

## Files

### Global — installed once, applies to every project

| File | What it is |
|---|---|
| `CLAUDE.md` | the always-loaded map: vocabulary, skill routing, the 11 rules that must not fail. **A map, not a manual** — loading everything at boot wastes the window and degrades recall |
| `harness/FORMATS.md` | single owner of every format: `PLAN.md`, `EPIC.md`, the behavior file, scenarios, states, reports, rubrics, runs, conventions. Skills point here and never redefine a format |
| `harness/PRINCIPLES.md` | 22 principles **with the reason for each**, plus how to adopt a new vs an existing project. A rule without its reason produces cargo cult |
| `harness/PROFILE.md` | who the user is and how to communicate with them. **This is the personal layer** — skills carry process, this file carries the person |
| `harness/LAYERS.md` | tools evaluated and rejected, each with the trigger that would reopen the decision |
| `harness/LEDGER.md` | global framework changes and cross-project candidates. Written only by `/harness` |
| `hooks/harness-route.sh` | `SessionStart` — injects the **route**, never the content: which epic is active, how many behaviors pending, where to look. Re-fires after compaction, which is the case that matters most |
| `hooks/harness-drift.sh` | `UserPromptSubmit` — a process sensor. Warns about work with no commit, no remote, two behaviors in progress. **Silent unless it has something concrete to say**, and each warning speaks once per session |
| `hooks/harness-guard.sh` | `PreToolUse` — the only hook that **blocks**: a commit or push carrying `.env`, `intake/`, a client spreadsheet or key material. Fails *open* if it cannot analyze, and has an escape valve (`.harness-allow`) |

### Per project — state only

| File | What it is |
|---|---|
| `AGENTS.md` | the repo's map, ~40 lines, routing only, no rules |
| `PLAN.md` | **Contract** (scope, out of scope, invariants) + **🔴 Blocked on you** + the epic index. The only file the human reads |
| `CONTEXT.md` | domain glossary — the terms this project uses and the synonyms to avoid |
| `docs/adr/` | durable decisions. Only if hard to reverse **and** surprising without context **and** a real trade-off |
| `specs/<epic>/EPIC.md` | the cycle of value, in functional language |
| `specs/<epic>/behaviors/` | **the work state.** One file per behavior, with parseable frontmatter — that is what makes boards, dependency waves, retries and tracker sync possible |
| `evals/rubrics/` | what counts as correct, in business language, **validated by the client** |
| `evals/runs/` | battery history with commit and rubric version. Answers "worse since when?" |
| `evals/target.md` | the adapter — how to run one input through the system. The only project-specific part of the eval layer |
| `intake/` | transcripts, contracts, screenshots. Dated, verbatim, **never pasted into the canon** — cited by path |
| `HARNESS.md` | agent telemetry: MISTAKES · LEARNINGS · DESIRES · FRICTION. One-way — the agent writes, the human reads |

### How the agent reads little while having a lot

```
AGENTS.md          L0 · the map — 40 lines, says where things live      ← every session
   ↓
behavior + ctx:    L1 · the 2–3 sources that govern THIS behavior       ← when it picks the behavior
   ↓
the intake file    L2 · opened only because ctx: pointed at it          ← on demand
```

Twelve transcripts in the repo and the agent never reads twelve. You read none — you read the
Contract and the 🔴 panel.

## External dependencies

**None of these are mine.** They are referenced, not bundled — install them from the source so
the authors get the traffic and you get their updates.

| What | Author | Role here | Install |
|---|---|---|---|
| **`grill-me`** and **`grill-with-docs`** | [Matt Pocock](https://github.com/mattpocock) | the interview engine. `grill-with-docs` owns the interrogation, the glossary and the ADRs — it asks one question at a time, challenges ambiguous terms, and writes the decision the moment it crystallizes | from Matt's skill collection into `~/.claude/skills/` |
| **Serena** | [oraios/serena](https://github.com/oraios/serena) | symbol-level code navigation via LSP, wired into `/feature`'s plan phase. `find_symbol` before writing anything is the internal half of the reuse gate | `claude mcp add -s user serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant` |
| **ponytail** | [DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail) | the posture during construction: the smallest thing that works, reuse before writing, abstraction only on repetition. It governs `/feature`'s execute phase | Claude Code plugin marketplace |

Everything degrades gracefully. Without Serena, `/feature` falls back to grep. Without the grill
skills, `/init-project` and `/epic` run the interview in their own voice.

**Boundary rule:** *grill decides the **what**, ponytail decides the **size**. Never in the same
turn.* Running ponytail during design produces shallow scope; running grill during the build
produces paralysis.

## Deliberately left out

Each of these was evaluated, understood, and rejected **for now**, with the trigger written down.
The point of recording the trigger is so the decision does not get re-litigated every time someone
recommends one of them. Full reasoning in [`harness/LAYERS.md`](harness/LAYERS.md).

| Not adopted | Why not | Trigger to reopen |
|---|---|---|
| **Wave orchestrator** — parallel execution, one git worktree per behavior, automatic retries. The design is already imported (waves, `status` as the agent↔orchestrator contract) | The manual cycle has not proven itself yet, and it needs commits and a test suite to operate on | the first epic running the full manual cycle end to end |
| **[OpenViking](https://github.com/volcengine/OpenViking)** (Volcengine / ByteDance) — a context database exposing memory, knowledge and skills as a virtual filesystem with L0/L1/L2 tiered loading | The L0/L1/L2 pattern is **already implemented in markdown** here (`AGENTS.md` → behavior + `ctx:` → intake file). Running a server for one person and four small projects does not pay for itself | files + grep genuinely failing, **or** adopting a cross-project orchestrator |
| **[Temporal](https://temporal.io/)** — durable workflow execution | An agent run is cheap to repeat and its state lives in git. `cron` + `claude -p` covers unattended work today | an unattended job long or multi-step enough that losing the middle costs hours or money |
| **A router orchestrator / "second brain"** — one general agent that receives work and delegates to per-project agents | With four projects I route for free and without hallucinating. Every extra hop is a lossy summarization of the one channel that should lose the least: my own intent. It also breaks session-per-behavior, since the executor ends up two layers away | when I stop being the one who initiates work — a consultant talking to the system directly, or work arriving by webhook. Reopens together with OpenViking |
| **[gstack](https://github.com/garrytan/gstack)** (Garry Tan) — 60 skills covering CEO review, design, QA, security, release | Its audience is founders deciding *what* to build (a client decision in my case) and tech leads with a PR flow on every change. Sixty skills reproduces my documented failure mode: too much, then I stop using it | with git and PRs running, evaluate **only** `/cso` (OWASP/STRIDE) and `/qa` (real browser), one at a time, by concrete pain. Never the bundle |
| **[Spec Kit](https://github.com/github/spec-kit) · [BMAD](https://github.com/bmad-code-org/BMAD-METHOD) · [OpenSpec](https://github.com/Fission-AI/OpenSpec)** | All solve the specification half; none has a client layer or semantic verification. BMAD in particular is heavy enough to change wall-clock materially | if this harness collapses under its own weight, OpenSpec is the lightest honest alternative |
| **A standalone `/simplify` skill** | Split in two: shrinking the diff is already inside `/feature` (and belongs there, before the commit); abstracting on repetition is inside `/review` (and can only live there, since it needs the whole epic merged) | wanting to run it over an entire codebase, outside the epic cycle |
| **A cross-project dashboard** | Deliberate. One workflow per project, no abstraction layer mixing them. The `🔴` panel per project is the whole cross-project view I need | more projects than I can hold in my head |

## Further reading — the material that shaped this

This is a synthesis of existing practice, not an invention. If you only read one thing, read the
first.

**[Harness engineering: leveraging Codex in an agent-first world](https://openai.com/index/harness-engineering/)**
— OpenAI. The essay that reframed the whole thing for me. The core claim is that you improve agent
output by shaping the **environment** around a fixed model, not by polishing prompts. The line that
changed my design most: *give the agent a map, not a thousand-page instruction manual* — they had a
monolithic agent manual, it grew until it was useless, and they replaced it with a small routing
file pointing at indexed documents. That is exactly what `AGENTS.md` and `CLAUDE.md` are here.

**[Harness engineering for coding agent users](https://martinfowler.com/articles/harness-engineering.html)**
— Martin Fowler. The practical half, aimed at people *using* agents rather than building them. It
gave me the distinction the whole sensor layer rests on: **guides** (feedforward — steer before the
fact) and **sensors** (feedback — catch after it), and why you need both. *"Separately, you get
either an agent that keeps repeating the same mistakes, or one that encodes rules and never finds
out whether they worked."* I had neither, which explained a lot.

**[harness-engineering](https://github.com/lopopolo/harness-engineering)** — Ryan Lopopolo. An
anthology and field guide, and the deepest single source here. Four ideas came from it directly:
just-in-time context routing (*deterministic context stuffing fails once work crosses several
compactions*), keeping durable intent sparse so it survives compaction, giving one agent the whole
job, and **agent-emitted telemetry** (`MISTAKES` / `LEARNINGS` / `DESIRES`) as a channel written
*for the harness builder* — which became `HARNESS.md` and the `/harness` skill.

**[Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)**
— Anthropic. Compaction, structured external note-taking, sub-agents with isolated context
returning distilled summaries, just-in-time retrieval via lightweight identifiers. The reason the
L0 → L1 → L2 layering exists, and the reason `/eval`'s judge runs in an independent context.

**[openai/symphony](https://github.com/openai/symphony)** — the tracker/repo split:
*repository-owned policy says how the work is done; the tracker records which outcomes are
available, blocked or complete.* It is why work state lives in parseable frontmatter and not in
prose — a program can read YAML, and no program reads a markdown checkbox.

Also read, and visibly present: **spec-driven development** as a category — the shift from
prompting to an executable specification as the source of truth — and **mutation testing** as a
test of the tests, which is decades old and still the only cheap way to find out whether a suite has
any value.

## What is actually mine

Narrower than the file count suggests, and worth being precise about:

- **The client layer** — the Contract with an explicit *out of scope*, `/intake` as a mutation
  operator on the behavior graph, the 🔴 panel, `cancelled` requiring a removal behavior when the
  code was already merged, `blocked` with a named owner so an external dependency never disguises
  itself as a failure.
- **The semantic scenario** — the merge point between testing and eval. A deterministic scenario and
  an AI eval case are the same object; the `Then` is verified by a test runner or by a judge against
  a versioned rubric.
- **The self-improvement loop** — `FRICTION` → `/harness` → a cross-project ledger, so the process
  gets fixed without the human having to notice it was broken.

Everything else is assembled from the material above.

## License

MIT for everything authored here. The external skills and MCP servers keep their own licenses —
see their repositories.

---

*If you use this and something breaks, the most useful thing you can send me is the `HARNESS.md`
your agent wrote. That file is the whole point.*
