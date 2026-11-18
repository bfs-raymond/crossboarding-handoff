#!/usr/bin/env bash
# install.sh — install crossboarding-handoff on this machine.
#
#   git clone https://github.com/<owner>/crossboarding-handoff ~/crossboarding-handoff
#   ~/crossboarding-handoff/install.sh
#
# Update later with `git pull` in the clone (everything is symlinked).
#
# What it does
#  - links handoff / pickup / handoff-done into ~/.local/bin (terminal use)
#  - links the skills into ~/.agents/skills and ~/.codex/skills (Codex and other Agent Skills runtimes)
#  - installs the Claude Code plugin from this local clone, if the claude CLI is present
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
SK="$HERE/plugins/crossboarding-handoff/skills"
SKILLS=(handoff pickup handoff-done)

mkdir -p "$HOME/.local/bin"
for s in "${SKILLS[@]}"; do
  ln -sfn "$SK/$s/scripts/$s.sh" "$HOME/.local/bin/$s"
done
echo "commands: ${SKILLS[*]} -> ~/.local/bin"

for d in "$HOME/.agents/skills" "$HOME/.codex/skills"; do
  mkdir -p "$d"
  for s in "${SKILLS[@]}"; do ln -sfn "$SK/$s" "$d/$s"; done
  echo "skills:   $d/{$(IFS=,; echo "${SKILLS[*]}")}"
done

case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *)
  echo "note: add ~/.local/bin to PATH  (echo 'export PATH=\"\$HOME/.local/bin:\$PATH\"' >> ~/.bashrc)";;
esac

if command -v claude >/dev/null; then
  if claude plugin marketplace add "$HERE" >/dev/null 2>&1 && \
     claude plugin install crossboarding-handoff@crossboarding-handoff >/dev/null 2>&1; then
    echo "Claude Code plugin installed: /handoff, /pickup, /handoff-done"
  else
    cat <<EOF
Install the Claude Code plugin from inside claude:
  /plugin marketplace add $HERE
  /plugin install crossboarding-handoff@crossboarding-handoff
EOF
  fi
fi
