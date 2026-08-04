# Framework ledger — global changes and cross-project candidates

Written and read **only by the `/harness` skill**. It exists to close two holes that
per-project triage has on its own:

1. **Cross-project blindness.** `/harness` runs inside one project and reads that project's
   `HARNESS.md`. If the same friction appears once in four different projects, each triage sees
   a single isolated occurrence and says "waiting for a 2nd" — forever. **Friction that repeats
   across projects is the strongest possible signal of a framework flaw**, and without this
   file it is invisible.
2. **Re-proposal.** With no record of what already changed, triage proposes the same thing
   again, or undoes an earlier decision without knowing.

---

## Applied — changes to the framework (`~/.claude/`)

Format: `YYYY-MM-DD · <file> · <what changed> · motivated by: <project(s) and occurrences>`

<!-- first entry when the first triage promotes something global -->

---

## Candidates — seen once in one project, waiting for a 2nd occurrence in ANOTHER

If a candidate here matches friction in the current triage **from a different project**, that
is a cross-project pattern: **promote now**, do not wait any longer.

Format: `YYYY-MM-DD · <project> · <the pattern> · <where it would be fixed>`

<!-- empty -->

---

## Rejected — global proposals the user decided not to apply

Recording the rejection keeps the same proposal from returning every week.

Format: `YYYY-MM-DD · <the proposal> · <reason for rejection>`

<!-- empty -->
