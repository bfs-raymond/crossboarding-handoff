---
name: handoff
description: Hand off the current coding work to another machine or another agent. Writes HANDOFF.md from this conversation's context, then commits everything to a wip/* branch and pushes it. Use when the user says handoff, hand this off, move this to another machine, I'm stopping here, 핸드오프, 다른 PC로 넘겨, 여기까지 하고 넘기자, or is about to stop working on this machine.
---

# handoff — move work to another machine

The point of this skill is that **you write HANDOFF.md yourself, from this conversation**.
Do not reconstruct it from git alone. Capture what was discussed, decided, tried and abandoned in this session.
On the next machine a different agent (Claude Code, Codex, agy, …) will continue from this document only.

## Steps

1. **Repo root**: `cd "$(git rev-parse --show-toplevel)"`. If this is not a git repo, stop and tell the user.

2. **Task name**: use the name the user gave. Otherwise, if the current branch is `wip/*` keep it; if not, pick a short kebab-case name for the work (e.g. `login-fix`).

3. **Write HANDOFF.md** at the repo root (overwrite). Write it in the language the user has been using. First line: `<!-- handoff: <hostname>, <YYYY-MM-DD HH:MM> -->`. Sections:
   - `## Goal` — what should be true when this work is done
   - `## Current state` — done / half-done / not started, including whether tests pass
   - `## Decisions and why` — include rejected alternatives, one line each
   - `## Next steps` — an actionable checklist (`- [ ]`); the first item names a concrete command or file
   - `## Pitfalls` — error messages, traps, things not to touch
   - `## Relevant files` — path plus one-line description
   - `## How to run` — commands to build, test and verify this work
   Never write secret values (.env contents, tokens, keys).

4. **Pre-commit check**: run `git status --short`. If large files or secret-looking files (.env, *.pem, *.key, credentials*.json, …) are about to be committed without being gitignored, **stop and ask the user**.

5. **Push**: HANDOFF.md is already written, so set `NOTE=0`. Find the script in this order:
   - `handoff` on PATH: `NOTE=0 handoff <task-name>`
   - otherwise this skill's bundled script: `NOTE=0 bash <this-skill-dir>/scripts/handoff.sh <task-name>`
     (as a Claude Code plugin: `${CLAUDE_PLUGIN_ROOT}/skills/handoff/scripts/handoff.sh`)

   If a commit hook fails, show the hook output to the user and fix the cause. Only re-run with `HANDOFF_NO_VERIFY=1` if the user explicitly asks to skip hooks.

6. **Report** two lines only:
   - the pushed branch name
   - how to continue elsewhere: `pickup <repo> <branch>`, or tell any agent "pickup <repo>"

## On failure

- "Local branch wip/... already exists" → re-run with a different task name.
- Push fails (auth) → suggest `gh auth status`. The commit is still local; nothing is lost.
