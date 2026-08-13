# Layers — what is in use and what stays out

Current truth as of 2026-08-04. No embedded history — history belongs to git.
Vocabulary and formats: `FORMATS.md`. The reasoning behind each rule: `PRINCIPLES.md`.

**The rule governing this file:** adopt when the pain hits, not when you hear about the tool.
New tool → find its layer → check the trigger. Without an observable trigger, do not adopt.
"Looks good" is not a trigger. Two tools in the same layer compete; they do not add up.

## In use

| # | Layer | Owner |
|---|---|---|
| 1 | How the agent finds code | **Serena** (MCP, symbol-level via LSP — adopted 2026-08-04, wired into `/feature` plan phase; falls back to grep/glob when unavailable) |
| 2 | How the agent knows the project | `AGENTS.md` (L0) · behavior + `ctx:` (L1) · the pointed-at intake file (L2) · `CONTEXT.md` · `docs/adr/` |
| 3 | What to do now | `PLAN.md` (Contract + 🔴 + epic index) · `specs/*/behaviors/` (work state, frontmatter) |
| 4 | Specify | `/init-project` · `/epic` (interview or prototype) · `/breakdown` · `grill-with-docs` · `grill-me` |
| 4 | Execute | `/feature` (plan → execute → verify, max 3 resets) + `ponytail` |
| 4 | Ingest external input and reconcile | `/intake` (archives + mutation operator on the graph) |
| 5 | What forces the loop | `SessionStart` hook (`~/.claude/hooks/harness-route.sh`) |
| 6 | Sensors — deterministic | `[deterministic]` scenarios → tests · mutation audit · full suite |
| 6 | Sensors — semantic | `[semantic]` scenarios → `/eval` (independent judge, versioned rubric, ratchet) |
| 6 | Sensors — human | `/review` (MERGE/FIX FIRST/RE-PLAN verdict) · blind review in sensitive zones |
| 7 | Execution without the human | `claude -p "/feature"` via cron/on-demand — only behaviors with scenarios; not refactors |

The 10 skills: `init-project` · `epic` · `breakdown` · `feature` · `intake` · `review` ·
`harness` · `eval` · `grill-me` · `grill-with-docs`.

## Known gap

**The git gate.** `/feature` **refuses to run** without `git rev-parse HEAD` — the gate is a
sensor, not a suggestion. Without a commit there is no per-attempt reset, and without reset the
3-attempt protocol is theater. A project that has not passed this gate gets no real verify, no
review and no orchestrator.

Record here whatever is currently missing in *your* setup — this section is the honest list of what
the harness does not yet cover, and the first thing `/harness` triage checks against.

## Evaluated and out — with the trigger to reopen

Do not reopen without the trigger. If someone recommends it again, the answer is already here.

**gstack** (`garrytan/gstack`) — layers 4 and 6. 60 skills.
Out: its audience is founders deciding what to build (a client decision here, not the user's)
and tech leads with a PR flow; 60 skills reproduces the known failure mode (too much → stops
using it). What was worth keeping arrived another way: semantic review and verification
discipline came from the team's internal kit.
→ **Trigger:** with git+PR running, evaluate **only** `/cso` (OWASP/STRIDE) and `/qa` (real
browser), by concrete pain. Never the bundle. `gbrain` always OFF (layer 2 is occupied).

**OpenViking** (`volcengine/OpenViking`) — layer 2. Context database, L0/L1/L2.
Out: the L0/L1/L2 pattern is already implemented in markdown (`AGENTS.md` → behavior+`ctx:` →
intake). Running a server for one person and four small projects does not pay for itself.
→ **Trigger:** files + grep genuinely failing, or adopting a cross-project orchestrator.

**Router orchestrator / second brain** — layers 4/7.
Out: with 4 projects the user routes for free and without hallucinating; every extra hop is a
lossy summarization of the one channel that should lose the least (their intent).
→ **Trigger:** when the user stops being the one who initiates work (a consultant talking to
the system directly, or work arriving by webhook). Reopens together with OpenViking.

**Temporal** — layer 7. Durable execution.
Out: an agent run is cheap to repeat and its state lives in git; cron + `claude -p` covers it.
→ **Trigger:** an unattended job long or multi-step enough that losing the middle costs hours
or money, or enough loops that retry visibility becomes necessary.

**Wave orchestrator (the team kit's `bin/workflow.mjs`)** — layer 7.
Manual contract active: the wave table lives in `EPIC.md`, one worktree isolates each behavior,
and integration into the epic branch is serial. Automatic launch, retry and cleanup code is not yet.
→ **Trigger:** one full wave completed through this manual worktree protocol. Then adapt the
orchestrator (it expects the `specs/<epic>/behaviors/` layout, compatible by construction).
