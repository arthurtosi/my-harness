# Principles and adoption

Why the framework has this shape, and how a project enters it. Formats: `FORMATS.md`.
Who the user is and how to communicate with them: `PROFILE.md`. Tool triage: `LAYERS.md`.

The rule governing this file: **a rule without its reason produces cargo cult** — a straw
plane that does not fly. If a workflow rule looks arbitrary, its reason is here.

---

## 1. The principles, with the reason

### On specification

1. **A behavior has a closed definition; a "feature" does not.** *A visible action, in a
   specific context, with an observable result.* That granularity is what makes automatic
   verification viable — failure is rare because each piece is very specific and very small.
2. **The scenario is the contract, and failure names the scenario.** "Handles errors
   gracefully" is not verifiable; "when the password is wrong, 'invalid credentials' appears
   and the field clears" is.
3. **Specification is LATE, at two levels.** A future epic is a name plus one line; its
   content is specified when its turn comes. A behavior is born a stub; its Technical Plan is
   written at execution time. *By the time behavior 32 runs, behaviors 1–31 have changed the
   codebase — planning early is planning against code that no longer exists.* It is also what
   keeps the plan from rotting: there is no future specification left to age.
4. **Out of scope is a required field.** It is what, months later, separates "the client
   asked for something new" from "the client thinks this was always included".

### On execution

5. **On failure, reset — do not pile on.** *Broken code in context contaminates the next
   attempts: the search stays stuck in the same basin of the distribution.* Extract the
   hypothesis, delete the code, start a fresh session.
6. **Maximum 3 attempts.** *Three failed hypotheses mean the problem is upstream* — ambiguous
   scenario, wrong dependency, architecture fighting the behavior. It is not execution, it is
   specification. There is no fourth attempt.
7. **Write the least code possible.** Code that does not exist has no bugs, needs no tests
   and never becomes a bad prompt for future generations. Hence the mandatory **reuse gate**:
   internal (a function that already exists) before external (a popular library) before
   writing anything new. Preference order: **use as is > extend with a parameter > extract the
   common part > write new.**
8. **Stay inside the distribution.** An LLM only does well what it has seen many times. A
   popular library before custom code; **search the web before choosing a stack** — the
   model's memory froze at training time and the ecosystem did not. And the project's codebase
   is out-of-distribution by definition, which is why it documents itself as it grows.
9. **The codebase is a prompt.** Every merged line becomes context for every future
   generation; mediocre code generated today is the pattern imitated tomorrow — compounding
   degradation. Hence: less code always, and **abstract only on repetition** (2–3
   occurrences), because a single-use abstraction abstracts nothing.
10. **A `done` behavior is never rewritten.** Something already delivered changed → new
    behavior. That is what prevents "the past tasks changed completely" — they stay as the
    record of what was delivered.

### On verification

11. **Reward hacking is the default behavior.** *The model optimizes the reward, not your
    intent: left alone it writes tests that always pass, mocks away the hard part, or edits
    the test until it goes green.* The prohibitions (never weaken a test, never mock what is
    under test) exist because the tendency is real.
12. **The mutation audit is a test of the tests.** Inject a deliberate bug; if no test
    breaks, the tests are decoration. It is the only way to know whether the suite has value
    without waiting for a production bug.
13. **The model knows things it does not use spontaneously.** It writes code with a security
    flaw and, asked immediately after, points out the flaw. That is why generating and
    auditing are **separate passes** — a prompt elicits one slice of the distribution and you
    have to pull the others.
14. **Review in the third person.** *In the training corpus, good review is always someone
    reviewing someone else's code.* The framing "another engineer wrote this" sharpens the
    critique — and it is free. In a sensitive zone (money, persisted data, auth) it escalates
    to a blind review: independent context, forbidden to name files or functions (if the
    reviewer cannot locate the region alone, that is already a finding).
15. **A scenario must be verifiable — by a program OR by a judge against a versioned rubric.
    "Vibes" are forbidden.** This is the rule that adapts the method to AI products: the
    source kit required programmatic verifiability, which is a wall when correctness is
    semantic. The spirit stays (no unverifiable scenarios); the wall comes down.
16. **The judge is independent and its prompt is generated, never authored.** A judge that is
    the same session agrees with itself. A hand-edited prompt makes every run use slightly
    different criteria — the score stops being comparable and the ratchet loses meaning.
17. **A wrong rubric ≠ a disobedient system.** When the client disagrees with a judgment, the
    question is not "fix the prompt" — these are two bugs with two different fixes. Confusing
    them makes you tune a prompt against a criterion that was wrong from the start.

### On context

18. **One fact, one owner.** If two files can answer the same question, one of them will lie.
19. **Context in three layers, loaded on demand.** `AGENTS.md` (L0, the map) → behavior +
    `ctx:` (L1, the 2–3 sources that govern THIS behavior) → the intake file (L2, opened only
    because `ctx:` pointed at it). *Deterministic context stuffing fails as soon as the work
    crosses several compactions.* Twelve transcripts in the repo and the agent never reads twelve.
20. **External input is an event, not context.** The transcript stays whole and dated in
    `intake/`; what it **changes** is distilled into the canon, with a link. Only the
    transcript → twelve transcripts and no truth. Only the canon → you cannot answer "who
    decided this, and when?".
21. **Durable intent stays sparse.** The user message carries the outcome, the acceptance bar
    and the authority boundary — not detailed policy. *Detailed policy in the user channel
    stays salient long after its work is over and smears attention across the whole job.*
22. **Durability is continuous.** Compaction is automatic and unannounced. Write state to the
    right owners before responding. What is not in a file does not exist.

---

## 2. Adoption — how a project enters the framework

**Nothing is duplicated.** The framework is an environment: the skills, the hooks and these
documents live in `~/.claude/` and apply to every project, present and future. What lives in
the project is only **state**: `AGENTS.md`, `PLAN.md`, `CONTEXT.md`, `specs/`, `evals/`,
`intake/`, `HARNESS.md`, `docs/adr/`.

### New project

```bash
mkdir <project> && cd <project> && git init
claude
```
Then `/init-project`, with the material at hand (contract, kickoff transcript, brand guide).
It interviews, writes the Contract + epic index + glossary + rubric v1, and assembles a
default-deny `.gitignore`. Nothing else to install.

### Existing project — the normal case, not the exception

The framework has to work on a project already in flight, otherwise it is useless.
`/init-project` does a **reverse reconstruction**: it reads the README, the stack manifest,
`git log`, existing docs and ADRs, and builds the epic index from **what is already delivered**.

**The principle that saves weeks of useless work: do not document the past as behaviors.**

- What is already delivered becomes **one `[x]` line** in the epic index. You do not write 40
  retroactive behaviors with scenarios — that is weeks of work with zero value. The record of
  the past is the index plus `git log` plus the code.
- What is half-done becomes the `[-]` epic, and **only the remaining part** gets behaviors.
- A behavior only exists **from now on**.
- **The exception, and it is lazy:** when an already-delivered behavior needs to be
  *modified*, then a behavior is born — with its own scenarios, at that moment. The past is
  specified on demand, only when touched.
- Existing AI product: the rubric and semantic scenarios also start from now. The judged set
  is seeded with what the client or the user can judge today; it is not reconstructed.

The gate is always the same: **git with a commit and a working `.gitignore`.** `/feature`
refuses to run without it — without a commit there is no reset, and without reset the
3-attempt protocol is theater.
