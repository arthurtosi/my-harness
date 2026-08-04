---
name: intake
description: Takes in ANY new external input — meeting transcript, chat screenshot, email, Discord or WhatsApp message, tender notice, contract, PDF, spreadsheet — archives it on its own under intake/ with a date and provenance, then reconciles it with the current plan by proposing a numbered diff over the behavior graph (new, changed, dead, blocked, judged scenarios, contradictions) for the user to approve in one batch. Use whenever the user pastes, attaches or describes something that came from outside — "this just came in", "look what the client sent", "just got out of the call", "the consultant said", "/intake" — even without an explicit request to reconcile.
---

# Take in external input and reconcile the plan

Two responsibilities, in this order: **archive** the input (you do it on your own — the user
never creates the file) and **reconcile** the plan with a diff they approve in one batch.

The reconciliation work is a **diff against the current plan, not a dump**. Input that only
appends items at the end is exactly how a plan rots: what already existed stays there, stale,
and the new thing becomes a duplicate.

Formats and states: `~/.claude/harness/FORMATS.md`. Nothing is applied without approval.

## 1. Archive the input — before any analysis

**Never ask the user to create the file.** They paste, attach or describe; you archive.

**a) Classify the zone** (`FORMATS §2`):

| Nature | Goes to |
|---|---|
| call transcript, meeting minutes, meeting summary | `intake/meetings/` |
| a message — Discord, WhatsApp, email, chat screenshot, transcribed audio | `intake/messages/` |
| a client document — contract, tender notice, PDF, Figma, spreadsheet, third-party spec | `intake/references/` |

**b) Find the date of the EVENT, not of the ingestion.** A transcript from Tuesday's call, pasted
today, is dated **Tuesday**. Look for the date in the content (transcript header, message
timestamp, document date). Cannot find it and it is ambiguous? Ask — one question, not a form.

**c) Name it and write it** to `intake/<zone>/YYYY-MM-DD-<slug>.md`:

```markdown
---
type: meeting | message | reference
date: YYYY-MM-DD            # of the event
source: Fathom | Discord | WhatsApp | email | screenshot | client PDF | ...
who: <participants or sender>
ingested: YYYY-MM-DD
---

<!-- Verbatim content below. NEVER edited, summarized or corrected. -->

<the content, in full>
```

Archiving rules:

- **Verbatim and complete.** Do not summarize, do not fix grammar, do not "clean it up". The
  summary becomes the diff (step 3); the raw material stays here. If it is long, it is long.
- **Screenshot / image**: transcribe faithfully what is in the image and mark `source: screenshot`
  in the header. If there is a file path, copy the image into `intake/references/` too and cite it.
- **A file already on disk** (PDF, spreadsheet, .docx): move it to the right zone with the naming
  pattern, and create a sibling `.md` with the header plus an index of what the document contains.
  A binary document is never pasted into the canon — it is cited by path.
- **Several inputs in one message** → one file per input, each with its own date.
- Transcripts get words wrong: a critical value (number, field name, deadline, monetary amount) is
  **approximate until confirmed** — mark `[??]` in the diff, do not record it as fact.

Confirm in chat, in one line: what you archived and where.

## 2. Read both sides

To be able to compare: the **Contract** and the epic index in `PLAN.md` · the frontmatter of every
behavior (one grep does it) · the ADR titles · `CONTEXT.md` · the rubrics.

## 3. Classify each item — the operations on the graph

Always look for the existing behavior or epic before creating one.

| Operation | When | What to propose |
|---|---|---|
| **New epic** | a capability the user did not have | **one line in the `PLAN.md` index** — do not specify it (that is `/epic`, when its turn comes) |
| **New behavior** | a new action inside an existing capability | a stub with scenarios and `depends_on`, in the right epic |
| **Changed (pending)** | changes the scope or a scenario of an unfinished behavior | edit the scenarios, showing **before → after** |
| **Changed (done)** | changes a behavior already merged | **do not edit: create a NEW behavior.** `done` is never rewritten |
| **Dead** | the client dropped it | `cancelled` + date + reason. **Already merged → a removal behavior** |
| **Blocked** | an external dependency appeared | `blocked` + `blocked_by` + a line in 🔴 with the owner named |
| **Scenario** | the client or user **judged a concrete example** | a new scenario (`[deterministic]` or `[semantic · rubric X]`) on the right behavior, `ctx:` pointing at this input. **A judgment is ground truth, not an anecdote** |
| **⚠️ Contradiction** | it collides with an ADR, a Contract invariant, or an **Out of scope** entry | **stop and escalate — never resolve it alone.** It is the most valuable finding here: the exact moment a project changes course without anyone noticing |
| **Glossary** | a term was defined, or used with two meanings | `CONTEXT.md` |
| **Deadline/Contract** | the project deadline or agreed scope changed | an edit to the **Contract** in `PLAN.md` — highlighted, never silent |

Rules that do not bend:

- **A vague request does not become a behavior** (*"improve the experience"*) → a line in 🔴 with
  the question that would make it executable. Without an observable result there is nothing to verify.
- **The client disagreed with an AI judgment?** The question is not "fix the prompt". It is:
  **is the rubric wrong, or did the system disobey the rubric?** Wrong rubric → revise it with the
  client, bump the version, reclassify affected cases (the score changes on purpose — not a
  regression). Disobedient system → a new behavior with the scenario as its contract.
- **Reopening an ADR decision** (user authorized): **invoke `grill-with-docs`** — it interviews the
  trade-off and writes the new ADR, marking the previous one superseded.
- **Input with nothing to reconcile is normal.** A contract archived for reference, a tender notice
  that only becomes `ctx:` — archive it, say "nothing to reconcile", and stop. Do not invent work.

## 4. Propose — numbered, self-contained, decidable without opening anything

```
Archived: intake/messages/2026-08-14-consultant-report-tweak.md
          (Discord · consultant · chat screenshot)

⚠️ CONTRADICTIONS (decide first)
1. They asked for <X>. ADR-0003 decided <Y> because <reason>.
   I recommend: <position + why>. Reopen?

NEW (2)
2. behavior <epic>/007 — <title> · scenarios: <summary> · depends on: 004
3. new epic in the index: "<slug> — <one sentence>"

CHANGED (1)
4. <epic>/003 · scenario "source offline": before <A> → after <B>

DEAD (1)
5. <epic>/005 — dropped. Already merged → includes removal behavior 008

JUDGED SCENARIOS (1)
6. ...

🔴 FOR YOU (1)
7. <decision or credential this input blocked or unblocked>
```

The user answers `1 yes, 2-6 apply, 7 later`.

## 5. Apply only what was approved

- Edit behaviors, `PLAN.md`, `CONTEXT.md`, rubrics — only what was approved, nothing more.
- **Add the input's path to the `ctx:`** of every behavior it originated or changed. That is how,
  months later, *"why does this exist and who decided it?"* has an answer.
- Report in one line what went in and what was left out.

## 6. No harness

No `PLAN.md`? Archive the input anyway (that always applies) and offer `/init-project` using it as
the primary material. Do not invent a plan from a single input.
