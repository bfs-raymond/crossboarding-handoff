# crossboarding-handoff

**Hand off coding work across machines and agents (Claude Code, Codex, agy) via git.**

Most handoff skills help a *new session on the same machine* resume work.
crossboarding-handoff moves the work itself: stop on one machine with one agent,
continue on another machine with any agent.

```
machine A (claude)                         machine B (codex, agy, claude…)
  /handoff login-fix                         /pickup myrepo
   ├─ agent writes HANDOFF.md from            ├─ clone/update ~/source/myrepo
   │  the live conversation                   ├─ switch to newest wip/* branch
   └─ commit + push wip/login-fix  ──git──▶   ├─ read HANDOFF.md, run its checks
                                                  └─ summarize, continue
                                               /handoff-done
                                                  └─ remove HANDOFF.md, open PR
```

- **Cross-machine** — HANDOFF.md travels on a `wip/*` branch instead of staying in a local folder.
- **Cross-agent** — plain [Agent Skills](https://agentskills.io) `SKILL.md`, so the same skills work in Claude Code and Codex; any other agent can be told to follow the file.
- **Verified pickup** — the receiving agent runs the documented build/test commands and reports whether reality matches the note before continuing.
- **Clean finish** — `handoff-done` strips HANDOFF.md and opens a PR; squash merge keeps wip commits out of history.

## Requirements

Linux or macOS (Windows: use WSL), `git`, a GitHub remote, and [`gh`](https://cli.github.com) (recommended; used for cloning and PRs).

## Install

On every machine you work on:

```bash
git clone https://github.com/bfs-raymond/crossboarding-handoff ~/crossboarding-handoff
~/crossboarding-handoff/install.sh
echo 'export GH_OWNER=<your-github-user>' >> ~/.bashrc   # so `pickup myrepo` works
```

Claude Code only, without the installer:

```
/plugin install crossboarding-handoff --marketplace bfs-raymond/crossboarding-handoff
```

Update with `git pull` in the clone. For the Claude Code plugin, bump `version` in `plugin.json` and `marketplace.json` when you change it, then update it from `/plugin`.

## Usage

| Where | Hand off | Pick up | Finish |
|---|---|---|---|
| Claude Code | `/handoff login-fix` or "hand this off" | `/pickup myrepo` | `/handoff-done` |
| Codex | `$handoff` | `$pickup myrepo` | `$handoff-done` |
| Other agents | "follow ~/.agents/skills/handoff/SKILL.md" | "follow ~/.agents/skills/pickup/SKILL.md for myrepo" | same pattern |
| Terminal | `handoff login-fix` | `pickup myrepo` | `handoff-done` |

Running it as a skill is the main path: the agent you were talking to writes HANDOFF.md with the full context of the session.
The terminal `handoff` is a fallback; it asks `claude -c -p` to write the note from the last Claude session in that directory.

## Configuration

| Variable | Default | Meaning |
|---|---|---|
| `SOURCE_ROOT` | `~/source` | where `pickup` clones repos |
| `GH_OWNER` | — | default owner for `pickup <repo>` |
| `NOTE` | `1` | `0` = terminal `handoff` does not write HANDOFF.md |
| `HANDOFF_NO_VERIFY` | `0` | `1` = skip git commit hooks (off by default so secret scanners still run) |

## What it does not do

- It does not sync agent session history (`~/.claude/projects`, `~/.codex/sessions`); HANDOFF.md replaces it.
- It does not move gitignored secrets (`.env`, keys). Use your own secret manager; `pickup` warns when `.env` is missing.
- `handoff` runs `git add -A`. Keep `.gitignore` tidy; the skill stops and asks if secret-looking files are about to be committed.

## 한국어 요약

여러 PC를 오가며 Claude Code, Codex, agy로 작업할 때 쓰는 스킬입니다.
`/handoff` 를 실행하면 지금 대화하던 에이전트가 HANDOFF.md를 쓰고 `wip/*` 브랜치로 push합니다. 다른 PC에서 `/pickup <repo>` 를 실행하면 받아서 상태를 확인한 뒤 이어서 작업합니다. 작업이 끝나면 `/handoff-done` 이 HANDOFF.md를 지우고 PR을 엽니다.
트리거 문구로 "핸드오프", "이어받아", "마무리하자"도 인식합니다.

## License

MIT
