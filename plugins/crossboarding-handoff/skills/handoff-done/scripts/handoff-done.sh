#!/usr/bin/env bash
# handoff-done — finish a wip/* branch: remove HANDOFF.md, push, and open a PR.
#
# Usage (on a wip/* branch):
#   handoff-done                 # PR into the default branch
#   handoff-done --base develop  # PR into another branch
#   handoff-done --title "..."   # custom PR title (default: from the branch name)
set -euo pipefail

base=""
title=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --base)  base="$2"; shift 2 ;;
    --title) title="$2"; shift 2 ;;
    *) echo "unknown option: $1" >&2; exit 1 ;;
  esac
done

cd "$(git rev-parse --show-toplevel)"
cur="$(git rev-parse --abbrev-ref HEAD)"
[[ "$cur" == wip/* ]] || { echo "Not on a wip/* branch (current: $cur)" >&2; exit 1; }

if [[ -n "$(git status --porcelain)" ]]; then
  echo "Uncommitted changes present. Commit them first." >&2
  git status --short >&2
  exit 1
fi

if [[ -f HANDOFF.md ]]; then
  git rm -q HANDOFF.md
  git commit -q -m "chore: remove HANDOFF.md before merge"
fi
git push -q origin "$cur"

if ! command -v gh >/dev/null; then
  echo "Pushed $cur without HANDOFF.md. gh not found — open the PR manually."
  exit 0
fi

[[ -n "$title" ]] || title="$(echo "${cur#wip/}" | tr '-' ' ')"
args=(--head "$cur" --title "$title" --body "Handed off across machines with crossboarding-handoff. Squash merge recommended.")
[[ -n "$base" ]] && args+=(--base "$base")

if gh pr view "$cur" >/dev/null 2>&1; then
  gh pr view "$cur" --json url -q .url
else
  gh pr create "${args[@]}"
fi
echo "Squash merge recommended so wip commits stay out of history."
