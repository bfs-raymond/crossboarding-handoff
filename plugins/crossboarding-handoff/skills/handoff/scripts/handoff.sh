#!/usr/bin/env bash
# handoff — push the current work to a wip/* branch so another machine can pick it up.
#
# Usage (inside a git repo):
#   handoff              # wip/<current-branch>
#   handoff login-fix    # wip/login-fix
#
# Environment:
#   NOTE=0               skip auto-writing HANDOFF.md (use when an agent already wrote it)
#   HANDOFF_NO_VERIFY=1  skip git commit hooks (off by default; hooks such as secret scanners stay on)
set -euo pipefail

top="$(git rev-parse --show-toplevel)"
cd "$top"
repo="$(basename "$top")"
cur="$(git rev-parse --abbrev-ref HEAD)"
task="${1:-}"
host="$(hostname -s 2>/dev/null || hostname)"
now="$(date '+%Y-%m-%d %H:%M')"

if [[ "$cur" == wip/* ]]; then
  wip="$cur"
else
  wip="wip/${task:-$cur}"
fi

# 1) HANDOFF.md — continue the last claude session in this directory so the note carries real context.
if [[ "${NOTE:-1}" == 1 ]]; then
  prompt="I'm handing this work off to another machine. Based on the work so far, output the contents of HANDOFF.md as markdown only.
Sections: ## Goal / ## Current state / ## Decisions and why / ## Next steps (checklist) / ## Pitfalls / ## Relevant files / ## How to run.
Be concrete enough that another agent (Claude Code, Codex, agy) can continue from this document alone. Never include secret values.
Write it in the same language the user has been using."
  tmp="$(mktemp)"
  if command -v claude >/dev/null && \
     { claude -c -p "$prompt" > "$tmp" 2>/dev/null || claude -p "$prompt" > "$tmp" 2>/dev/null; } && [[ -s "$tmp" ]]; then
    { echo "<!-- handoff: $host, $now, from $cur -->"; cat "$tmp"; } > HANDOFF.md
    echo "HANDOFF.md written (claude)"
  else
    {
      echo "<!-- handoff: $host, $now, from $cur -->"
      echo "## Current state"; echo; echo '```'; git status --short; echo '```'
      echo "## Recent commits"; echo; echo '```'; git log --oneline -10; echo '```'
      echo "## Next steps"; echo; echo "- [ ] (fill in)"
    } > HANDOFF.md
    echo "HANDOFF.md template written (claude unavailable) — please fill it in"
  fi
  rm -f "$tmp"
fi

# 2) Switch to the wip branch (uncommitted changes come along).
if [[ "$cur" != "$wip" ]]; then
  if git show-ref --verify --quiet "refs/heads/$wip"; then
    echo "Local branch $wip already exists. Re-run with another name: handoff <name>" >&2
    exit 1
  fi
  git switch -c "$wip"
fi

# 3) Commit & push.
verify=()
[[ "${HANDOFF_NO_VERIFY:-0}" == 1 ]] && verify=(--no-verify)
git add -A
if git diff --cached --quiet; then
  echo "Nothing to commit"
else
  git commit -q ${verify[@]+"${verify[@]}"} -m "wip: handoff from $host ($now)"
fi
git push -q -u origin "$wip"

echo
echo "Done: $repo @ $wip"
echo "On another machine:  pickup $repo $wip"
