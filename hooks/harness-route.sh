#!/bin/bash
# SessionStart — injects the ROUTE (never the content) when the repo has the harness installed.
# Contract: silent and exit 0 in every other case. It must never break a session start.
# Applies to startup, resume and compact — post-compaction rehydration is the case that matters most.

set -u

cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
[ -f PLAN.md ] || exit 0

# Epic in progress: the first LIST line marked [-] in the PLAN.md index.
# Anchored to the start of the line ("1. [-] x" or "- [-] x") on purpose: searching for '[-]'
# anywhere also matched code examples and prose notes.
epic=$(grep -m1 -E '^[[:space:]]*([0-9]+\.|[-*])[[:space:]]+\[-\]' PLAN.md 2>/dev/null \
       | sed -E 's/^[[:space:]]*([0-9]+\.|[-*])[[:space:]]+\[-\][[:space:]]*//')
[ -n "$epic" ] || epic="none in progress"

# Work state: behaviors under specs/*/behaviors/*.md (parseable frontmatter)
pend=0; prog=""
if [ -d specs ]; then
  pend=$(grep -rl '^status: pending' specs 2>/dev/null | grep -c '/behaviors/' 2>/dev/null || true)
  prog=$(grep -rl '^status: in_progress' specs 2>/dev/null | grep '/behaviors/' 2>/dev/null | head -1 || true)
fi
pend=$(printf '%s' "$pend" | tr -cd '0-9'); [ -n "$pend" ] || pend=0

detail="Pending behaviors: ${pend}."
[ -n "$prog" ] && detail="${detail} In progress: ${prog}."

# This text is a hint, not data: sanitizing is safer than escaping (JSON valid by construction).
epic=$(printf '%s' "$epic" | tr -d '\\"' | tr -d '\000-\037')
detail=$(printf '%s' "$detail" | tr -d '\\"' | tr -d '\000-\037')

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"This repository uses the project harness (formats: ~/.claude/harness/FORMATS.md). Read AGENTS.md (the map) and the top of PLAN.md (Contract + the red panel) before acting, and load only the context slice the behavior asks for — not the whole repo. Work enters through /feature; any external input (transcript, screenshot, email, contract) through /intake; a new epic through /epic and /breakdown. No change without a behavior. Epic in progress: %s. %s"}}\n' "$epic" "$detail"
exit 0
