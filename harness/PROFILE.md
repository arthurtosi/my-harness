# User profile

Who the user is and how to communicate with them. **This is the personal layer** — the skills
carry process, this file carries the person. Every rule here overrides a communication default
in a skill.

Fill it in for yourself. The lines below are a working example; replace them.

---

## Who

The user is an **orchestrator and AI engineer**, not a project manager. They run ~4 client
projects in parallel.

## How to communicate — non-negotiable

- **They do not read code or specs.** They open a file only to write something, or when the
  agent tells them to look. What they read: the **chat**, the **Contract** and the **🔴** panel
  of `PLAN.md`. If it is not there, for them it does not exist.
- **Never reference internal state as if they were following along** ("that behavior", "as we
  saw"). Re-present the minimum context every time.
- **Every question to them is self-contained**: situation + options + your recommendation,
  decidable without opening anything.
- **When instructing an action of theirs, hand it over ready**: the exact command, the
  `file:line`, the text pasted in. Never "check the plan".
- **Human validation is a BATCH, not a step.** Do not offer testing or deploy as the next step
  in the middle of work: accumulate and announce once.
- **Authority**: engineering (library, pattern, how to test, keep vs revert) belongs to the
  agent — decide and execute, even among valid options. Escalate only what changes **product,
  scope or cost**, or depends on an **external fact / credential / client decision**.
- **One session per behavior.** When a behavior closes, **propose a fresh session** instead of
  chaining into the next — state lives entirely in files and a new session starts clean. Chain
  only when they ask ("keep going", "do the whole wave").
- **If they are drifting off-process, say so** — one line, with the alternative. Examples:
  asking for code with no behavior, piling up uncommitted work, using one session for many
  things. Warning is mandatory; insisting after they decide is not.

## Work context

Demand arrives from a consultant (chat, high-level, **no per-task deadlines** — only a project
deadline), for the user to break down. Client meetings arrive as full transcripts.
The user is the router between projects — which is why there is no cross-project orchestrator
agent (`LAYERS.md`).

## Known failure mode

Adopting a method, using it well at the start, and abandoning it halfway back to firing loose
prompts. It is not indiscipline — it is economics: typing a prompt costs 5 seconds, opening the
plan costs 2 minutes, and the cheaper option always wins.

That is why the framework **does not depend on remembering to use it**: `/feature` is shorter
than any prompt, the `SessionStart` hook re-injects the route on its own, and a loose request
becomes a behavior before it becomes code. The defense is the harness, not discipline.
