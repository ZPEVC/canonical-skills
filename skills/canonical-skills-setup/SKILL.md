---
name: canonical-skills-setup
description: Set up a vendor-agnostic canonical skills directory and wire it to all local agent clients via symlinks. Use when setting up skills on a new machine or adding a new agent client.
argument-hint: [canonical-path]
disable-model-invocation: true
---

# Canonical Skills Setup

A pattern for storing agent skills in a single version-controlled location and making them available across every agent client — without duplicating files or locking into any one vendor's directory structure.

## The Problem

Every agent client (Claude Code, Gemini CLI, VS Code Copilot, etc.) discovers skills from its own directory. Without a canonical source, you end up with:

- Duplicated skill files across `~/.claude/skills/`, `~/.agents/skills/`, `.github/skills/`, etc.
- Skills that drift out of sync across agents
- Loss of all skills if you delete a vendor's config folder

## The Solution

Store skills once in a version-controlled repo. Wire each agent client to that source via symlinks.

```
~/your-repo/skills/          ← canonical source (version controlled)
    my-skill/
        SKILL.md

~/.claude/skills/my-skill    → ~/your-repo/skills/my-skill   (symlink)
~/.agents/skills/my-skill    → ~/your-repo/skills/my-skill   (symlink)
```

Each agent reads its own directory. All symlinks point to the same source. Edit once, available everywhere.

## Setup

### 1. Run the bootstrap script

```bash
bash ~/.claude/skills/canonical-skills-setup/scripts/bootstrap.sh [canonical-path]
```

- `canonical-path` defaults to `~/Projects/knowledge-base/skills`
- Run it on any new machine after cloning your canonical repo

### 2. Add a new skill

```bash
mkdir -p ~/your-repo/skills/my-skill
# write ~/your-repo/skills/my-skill/SKILL.md
bash ~/.claude/skills/canonical-skills-setup/scripts/bootstrap.sh
```

The bootstrap script is idempotent — safe to re-run any time.

## Supported Agent Clients

| Agent | Discovery Path |
|---|---|
| Claude Code | `~/.claude/skills/` |
| Gemini CLI / Antigravity | `~/.agents/skills/` |
| VS Code Copilot | `.github/skills/` (project-level) |

## File Structure

```
canonical-skills-setup/
├── SKILL.md              ← this file
└── scripts/
    └── bootstrap.sh      ← symlink wiring script
```

## Related

- [agentskills.io](https://agentskills.io) — open standard this pattern is built on
- `SKILL.md` spec: [agentskills.io/specification](https://agentskills.io/specification)
