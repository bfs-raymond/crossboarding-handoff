---
name: pickup
description: Pick up coding work that was handed off from another machine or agent. Clones or updates the repo, switches to the newest wip/* branch, reads HANDOFF.md, verifies the state and continues. Use when the user says pickup, pick up, continue <repo>, resume the handoff, 픽업, 이어서 하자, 이어받아, 넘긴 작업 가져와, or names a repo to continue on this machine.
---

# pickup — continue handed-off work

## Steps

1. **Target**: the repo name (or `owner/repo`) the user gave, plus a branch if they named one. If no repo was given, ask.

2. **Run the script**, found in this order:
   - `pickup` on PATH: `pickup <repo> [branch]`
   - otherwise this skill's bundled script: `bash <this-skill-dir>/scripts/pickup.sh <repo> [branch]`
     (as a Claude Code plugin: `${CLAUDE_PLUGIN_ROOT}/skills/pickup/scripts/pickup.sh`)

   It clones/updates into `$SOURCE_ROOT/<repo>` (default `~/source/<repo>`) and, without a branch, switches to the newest `wip/*` branch. It prints the path.
   - "set GH_OWNER" error → ask the user for the GitHub owner and re-run as `owner/repo`.
   - "uncommitted changes" error → **do not discard anything**; ask the user what to do.

3. **Work in that directory** from now on.

4. **Read HANDOFF.md** fully, then the files under `Relevant files` as needed.

5. **Verify**: if `.env.example` exists but `.env` does not, tell the user (never invent values). Run the commands under `How to run` once and compare the result with `Current state`.

6. **Summarize** for the user in at most 5 lines:
   - branch, and which host handed it off and when
   - current state, and whether verification matched the document
   - the immediate next step
   Then ask "Continue?". If the user already said to continue, skip the question and start with the first `Next steps` item.

7. While working, keep the `Next steps` checklist in HANDOFF.md up to date so the next handoff starts from it.

8. When every item is done, suggest finishing with the `handoff-done` skill (removes HANDOFF.md and opens a PR).
