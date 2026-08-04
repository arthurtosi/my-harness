# Install

**For the agent.** The user cloned this repository and asked you to install it. Your job is to copy
this harness into their `~/.claude/` and fill in their profile. Work through the steps in order.

Nothing here is destructive by default: every collision is reported and the user decides.

## 1. Show what will happen, then wait for a yes

You are about to write into the user's global Claude Code configuration. List exactly:

- copy `skills/*` → `~/.claude/skills/` (8 skills: init-project, epic, breakdown, feature, intake,
  review, eval, harness)
- copy `hooks/*.sh` → `~/.claude/hooks/` and `chmod +x`
- copy `harness/*.md` → `~/.claude/harness/`
- **merge** a `hooks` block into `~/.claude/settings.json` (never overwrite — see step 3)
- create or update `~/.claude/CLAUDE.md` (see step 4)

**Name any collision explicitly.** If a file already exists at the destination with different
content, say which, and ask: overwrite, skip, or keep both (`.new` suffix)? Never silently
overwrite something the user wrote.

If `~/.claude/` is not under git, say so once: *"~/.claude/ has no version control — a rollback for
your own framework is worth ten seconds"*, and offer the commands. Do not run them.

## 2. Copy the files

Straightforward `cp`. Then `chmod +x ~/.claude/hooks/*.sh`.

## 3. Merge the hooks into `settings.json` — merge, never overwrite

Read `~/.claude/settings.json`. If it does not exist, create it as `{}` first.

Add the three entries below **into the existing `hooks` key** if there is one, preserving every
hook the user already has. If a hook with the same command is already registered, skip it.

```json
{
  "hooks": {
    "SessionStart": [
      { "hooks": [ { "type": "command", "command": "bash ~/.claude/hooks/harness-route.sh" } ] }
    ],
    "UserPromptSubmit": [
      { "hooks": [ { "type": "command", "command": "bash ~/.claude/hooks/harness-drift.sh" } ] }
    ],
    "PreToolUse": [
      { "matcher": "Bash",
        "hooks": [ { "type": "command", "command": "bash ~/.claude/hooks/harness-guard.sh" } ] }
    ]
  }
}
```

Expand `~` to the absolute home path in the commands you write — some shells do not expand it here.

**Show the user the before and after of `settings.json`**, then validate it parses
(`python3 -m json.tool`). A broken `settings.json` breaks every future session, so validation is
not optional. If it does not parse, restore the original and stop.

## 4. `~/.claude/CLAUDE.md` — the always-loaded map

This repository does not ship one, because that file is personal. Create it if absent, or **append
a section** if the user already has one. It must carry, short and as routing only:

- the vocabulary: **Project → Epic → Behavior**, and that nothing exists below a behavior
- the routing table: which skill for which situation (the 8 installed, plus `grill-me` /
  `grill-with-docs` / `ponytail` if the user installs them — step 6)
- the rules that must not fail — take them from `harness/PRINCIPLES.md`, as pointers, not copies
- a pointer to `~/.claude/harness/PROFILE.md`
- where the rest lives: `FORMATS.md`, `PRINCIPLES.md`, `PROFILE.md`, `LAYERS.md`, `LEDGER.md`

Keep it under ~60 lines. It loads in every session — it is a map, not a manual.

## 5. Fill in `PROFILE.md` — four questions, one at a time

`~/.claude/harness/PROFILE.md` ships as a working example of someone else's profile. Replace it.
Ask, one at a time, waiting for each answer:

1. What is your role, and how many projects do you run in parallel?
2. Do you read code and specs, or do you want to read only the chat and a status panel?
3. Should the agent decide engineering choices (library, pattern, how to test) on its own, or ask you?
4. One session per behavior, or chain through the whole wave?

Rewrite `PROFILE.md` from the answers, keeping the file's structure. This is the personal layer:
the skills carry process, this file carries the person.

## 6. Tell them about the external pieces — do not install them

Three things this repo references and deliberately does not bundle (they are not ours):

- **`grill-me` / `grill-with-docs`** (Matt Pocock) — the interview engine. `/init-project` and
  `/epic` call `grill-with-docs`; without it they run the interview in their own voice.
- **Serena** (`oraios/serena`) — symbol-level code navigation, used in `/feature`'s plan phase.
  `claude mcp add -s user serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant`
- **ponytail** (`DietrichGebert/ponytail`) — the posture during construction.

Everything degrades gracefully without them. Hand over the install commands; **do not run them.**

## 7. Close

1. Tell the user, self-contained: what was installed, what collided and how it was resolved, what
   is still missing (the external pieces, `~/.claude/` under git), and that **the hooks only take
   effect in the next session** — `settings.json` is read at boot.
2. The first real step: `cd <a-project> && git init && claude`, then `/init-project`.
