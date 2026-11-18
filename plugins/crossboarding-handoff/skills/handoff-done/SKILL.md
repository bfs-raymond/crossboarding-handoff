---
name: handoff-done
description: Finish handed-off work on a wip/* branch — remove HANDOFF.md, push, and open a pull request. Use when the user says handoff done, finish this wip, open the PR, wrap up, 작업 끝, 마무리하자, PR 올려, or when every item in HANDOFF.md's Next steps is checked.
---

# handoff-done — finish a wip branch

## Steps

1. Confirm the current branch is `wip/*`. If not, tell the user and stop.

2. Check HANDOFF.md: if any `Next steps` items are unchecked, list them and ask whether to finish anyway.

3. Run the verification commands under `How to run`. If they fail, report it and ask before continuing.

4. Commit any remaining changes with a normal commit message describing the work (not "wip").

5. Run the script, found in this order:
   - `handoff-done` on PATH: `handoff-done [--base <branch>] [--title "<title>"]`
   - otherwise: `bash <this-skill-dir>/scripts/handoff-done.sh ...`
     (as a Claude Code plugin: `${CLAUDE_PLUGIN_ROOT}/skills/handoff-done/scripts/handoff-done.sh`)

   Pass a `--title` that describes the change, written from the HANDOFF.md goal.

6. Report the PR URL and recommend a squash merge so wip commits stay out of history.
