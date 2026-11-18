#!/usr/bin/env bash
# pickup — continue work that another machine handed off.
#
# Usage:
#   pickup <repo>                 # $GH_OWNER/<repo>, newest wip/* branch
#   pickup <owner/repo> <branch>  # explicit branch
#   pickup <repo> main            # start from a normal branch
#
# Environment:
#   SOURCE_ROOT  where repos live (default: ~/source)
#   GH_OWNER     default GitHub owner when only <repo> is given
set -euo pipefail

[[ $# -ge 1 ]] || { echo "usage: pickup <repo|owner/repo> [branch]" >&2; exit 1; }
spec="$1"
branch="${2:-}"
SRC="${SOURCE_ROOT:-$HOME/source}"

if [[ "$spec" != */* ]]; then
  : "${GH_OWNER:?set GH_OWNER or pass owner/repo}"
  spec="$GH_OWNER/$spec"
fi
name="${spec##*/}"
dir="$SRC/$name"

mkdir -p "$SRC"
if [[ ! -d "$dir/.git" ]]; then
  if command -v gh >/dev/null; then
    gh repo clone "$spec" "$dir"
  else
    git clone "git@github.com:$spec.git" "$dir"
  fi
fi
cd "$dir"

if [[ -n "$(git status --porcelain)" ]]; then
  echo "$name has uncommitted changes on this machine. Hand them off or clean up first." >&2
  git status --short >&2
  exit 1
fi

git fetch -q --all --prune

if [[ -z "$branch" ]]; then
  branch="$(git for-each-ref --sort=-committerdate --format='%(refname:lstrip=3)' 'refs/remotes/origin/wip/*' | head -1)"
  [[ -n "$branch" ]] || branch="$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')"
  [[ -n "$branch" ]] || branch="main"
fi

if git show-ref --verify --quiet "refs/heads/$branch"; then
  git switch -q "$branch"
  git pull -q --ff-only
else
  git switch -q -c "$branch" --track "origin/$branch"
fi
echo "== $name @ $branch ($(git log -1 --format='%h %s'))"
echo "== path: $dir"

# Match runtime versions if mise is available.
if command -v mise >/dev/null && \
   [[ -f mise.toml || -f .mise.toml || -f .tool-versions || -f .nvmrc || -f .python-version ]]; then
  mise install -q || true
fi

for f in .env.example .env.sample; do
  [[ -f "$f" && ! -f .env ]] && echo "!! .env missing — copy it from the previous machine or create it from $f"
done

if [[ -f HANDOFF.md ]]; then
  echo
  echo "=================== HANDOFF.md ==================="
  cat HANDOFF.md
  echo "=================================================="
fi
