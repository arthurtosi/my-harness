#!/bin/bash
# PreToolUse (matcher: Bash) — GUARD against leaking secrets or client data into git.
#
# PHILOSOPHY: this is the ONLY hook that BLOCKS, and only on the irreversible (a secret in git
# history; rewriting history is expensive and leaks anyway if it was already pushed). A guard that
# blocks legitimate commands becomes a disabled guard — hence ANCHORED patterns and an escape valve.
#
# FAIL-OPEN by decision: if it cannot analyze, it ALLOWS. It is the 2nd wall (the 1st is the
# default-deny .gitignore); a broken hook must not lock up all of Bash.
#
# ESCAPE VALVE: create `.harness-allow` at the repo root, one pattern (regex) per line. A file
# matched by it never blocks. Commit that file — it is a record of policy.

set -u
payload=$(cat 2>/dev/null || true)
[ -n "$payload" ] || exit 0

cmd=$(printf '%s' "$payload" | python3 -c 'import json,sys
try: print(json.load(sys.stdin).get("tool_input",{}).get("command",""))
except Exception: print("")' 2>/dev/null) || exit 0
[ -n "$cmd" ] || exit 0

# A git command that PUBLISHES or FREEZES content.
# Tolerates global flags between "git" and the subcommand (-C <path>, -c k=v, --git-dir=...),
# which was the false negative: `git -C /x commit` slipped through.
GITPUB='(^|[;&|(]|&&|\|\|)[[:space:]]*git([[:space:]]+(-[A-Za-z]|--[a-z-]+)([[:space:]]*=?[^[:space:]]+)?)*[[:space:]]+(commit|push|add[[:space:]]+(-A|--all|\.))'
printf '%s' "$cmd" | grep -qE "$GITPUB" || exit 0

cd "${CLAUDE_PROJECT_DIR:-$PWD}" 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

# ANCHORED patterns: they match a path or file name, not a word inside a name.
# (A bare `secret` was removed: it blocked docs/secrets-policy.md and src/secretary.py.
#  `intake/` is anchored to the ROOT with ^ : the documented layout puts the project's intake
#  folder at the repo root, and `(^|/)intake/` also matched skills/intake/ — blocking this
#  framework's own skill. A false positive that blocks legitimate code disables the guard.)
CFGEXT='(env|json|ya?ml|txt|ini|toml|cfg|conf|csv)'
# Key material: blocked by EXTENSION regardless of name — a private key is a secret even when
# called "prod.pem". Deliberate asymmetry: blocking a public cert is an annoyance with an escape
# valve; leaking a private key is a catastrophe.
KEYEXT='(pem|key|p12|pfx|jks|keystore|asc|gpg|ppk)'
CONF="(^|/)\.env(\$|\.[^/]*\$)|^intake/|(^|/)\.data/|(^|/)(credentials|credenciais|secrets?|segredos?)[^/]*\.${CFGEXT}\$|(^|/)[^/]*\.${KEYEXT}\$|(^|/)[^/]*\.(xlsx|xls|csv|msg|eml)\$"

targets=$( { git diff --cached --name-only 2>/dev/null; \
             printf '%s' "$cmd" | grep -qE 'add[[:space:]]+(-A|--all|\.)' && \
               git add -A --dry-run 2>/dev/null | sed -E "s/^add '//; s/'\$//"; } | sort -u )

found=$(printf '%s\n' "$targets" | grep -iE "$CONF" || true)
[ -n "$found" ] || exit 0

# Escape valve: drop whatever the repo explicitly authorized
if [ -f .harness-allow ]; then
  patterns=$(grep -vE '^[[:space:]]*(#|$)' .harness-allow 2>/dev/null || true)
  if [ -n "$patterns" ]; then
    found=$(printf '%s\n' "$found" | grep -vE "$(printf '%s' "$patterns" | paste -sd'|' -)" || true)
  fi
fi
[ -n "$found" ] || exit 0

{
  echo "BLOCKED by the harness guard — the set about to be committed/pushed matches a CONFIDENTIAL pattern:"
  printf '%s\n' "$found" | head -8 | sed 's/^/  - /'
  echo ""
  echo "A secret or client data in git history is IRREVERSIBLE."
  echo ""
  echo "If it should NOT be versioned (the normal case):"
  echo "  1. add it to .gitignore (default-deny: .env*, intake/, client spreadsheets and PDFs)"
  echo "  2. git restore --staged <file>      # unstage it"
  echo "  3. git diff --cached --name-only    # confirm it is gone"
  echo ""
  echo "If it SHOULD be versioned and the user explicitly authorized it:"
  echo "  add the pattern (one regex per line) to .harness-allow at the repo root."
  echo "  e.g.: echo 'tests/fixtures/.*\\.csv\$' >> .harness-allow"
  echo "  That file is a record of policy — commit it."
  echo ""
  echo "If this block is a recurring FALSE POSITIVE, it is a bug in the guard: record it in"
  echo "HARNESS.md (DESIRES) and tell the user — a guard that blocks the legitimate gets disabled."
} >&2
exit 2
