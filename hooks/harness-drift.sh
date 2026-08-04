#!/bin/bash
# UserPromptSubmit — PROCESS DRIFT sensor.
#
# PHILOSOPHY: it blocks nothing and judges nothing. It checks facts that ARE deterministic
# (git state, file existence) and hands the judgment to the model. Worst case it gives a wrong
# hint — it never prevents work.
#
# ANTI-NOISE: each warning type speaks ONCE per session. A sensor that repeats itself on every
# message becomes noise, and noise ends in a disabled hook.
#
# Exit 0 always. Silence is the default.

set -u
cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
[ -f PLAN.md ] || exit 0   # outside a harness project: total silence, zero tokens

payload=$(cat 2>/dev/null || true)
sid=$(printf '%s' "$payload" | python3 -c 'import json,sys
try: print(json.load(sys.stdin).get("session_id","") or "")
except Exception: print("")' 2>/dev/null) || sid=""
[ -n "$sid" ] || sid="pid$PPID"
memo="${TMPDIR:-/tmp}/harness-drift-$(printf '%s' "$sid" | tr -cd 'A-Za-z0-9_-' | cut -c1-64)"

warnings=""
# add <key> <text> — emits only if this key has not spoken yet in this session
add() {
  grep -qxF "$1" "$memo" 2>/dev/null && return 0
  printf '%s\n' "$1" >> "$memo" 2>/dev/null
  warnings="${warnings}${warnings:+ }$2"
}

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  add gate-nogit "GATE: this project is not under git. /feature does not run without a commit (no commit means no attempt reset). Assemble the default-deny .gitignore and leave the initial commit ready for the user to run."
elif ! git rev-parse HEAD >/dev/null 2>&1; then
  add gate-nocommit "GATE: repo with no commits at all. /feature does not run like this; .env and client data are untracked and there is no rollback."
else
  dirty=$(git status --porcelain 2>/dev/null | grep -cv '^??' || true)
  dirty=$(printf '%s' "$dirty" | tr -cd '0-9'); [ -n "$dirty" ] || dirty=0
  [ "$dirty" -ge 25 ] && add dirty "HYGIENE: ${dirty} modified files with no commit — a volume high enough to suggest something ran outside the behavior cycle. Check (it may be legitimate in a large behavior)."

  if git rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
    unpushed=$(git log '@{u}..' --oneline 2>/dev/null | wc -l | tr -cd '0-9'); [ -n "$unpushed" ] || unpushed=0
    [ "$unpushed" -ge 15 ] && add push "HYGIENE: ${unpushed} commits not pushed. Suggest the command (do not execute it)."
  else
    add noremote "HYGIENE: branch has no remote — nothing is backed up off this machine."
  fi
fi

if [ -d specs ]; then
  prog=$(grep -rl '^status: in_progress' specs 2>/dev/null | grep '/behaviors/' || true)
  n=$(printf '%s\n' "$prog" | grep -c . || true); n=$(printf '%s' "$n" | tr -cd '0-9'); [ -n "$n" ] || n=0
  [ "$n" -ge 2 ] && add multiprog "STATE: ${n} behaviors are in_progress at the same time. One behavior per session is the user's preference — confirm which one is active and set the other back to pending."
fi

[ -n "$warnings" ] || exit 0

warnings=$(printf '%s' "$warnings" | tr -d '\\"' | tr -d '\000-\037')
printf '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"[process sensor — a hint, not an order] %s | Tell the user in ONE line, with the alternative. If they decide to proceed anyway, proceed without insisting. If the warning is wrong, ignore it and record it in HARNESS.md (DESIRES)."}}\n' "$warnings"
exit 0
