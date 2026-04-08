# canonical-skills

A vendor-agnostic pattern for managing [Agent Skills](https://agentskills.io) across multiple AI agent clients without duplication or vendor lock-in.

## The problem

Every agent client stores skills in its own directory:

| Agent | Skills path |
|---|---|
| Claude Code | `~/.claude/skills/` |
| Gemini CLI / Antigravity | `~/.agents/skills/` |
| VS Code Copilot | `~/.copilot/skills/` |

Without a canonical source, you end up copying the same `SKILL.md` files everywhere. They drift out of sync, and deleting one vendor's config folder takes your skills with it.

## The solution

Store your skills once in a version-controlled repo. Use symlinks to wire each agent client to that single source.

```
~/your-repo/skills/           ← canonical source (version controlled)
    my-skill/
        SKILL.md

~/.claude/skills/my-skill     → ~/your-repo/skills/my-skill   (symlink)
~/.agents/skills/my-skill     → ~/your-repo/skills/my-skill   (symlink)
~/.copilot/skills/my-skill    → ~/your-repo/skills/my-skill   (symlink)
```

Edit a skill once. Every agent sees the update immediately.

## Quick start

### 1. Install the bootstrap skill

```bash
npx skills add -g ZPEVC/canonical-skills
```

### 2. Create your canonical directory

```bash
mkdir -p ~/your-repo/skills
```

### 3. Run the bootstrap

```bash
bash ~/.claude/skills/canonical-skills-setup/scripts/bootstrap.sh ~/your-repo/skills
```

The script creates symlinks from each agent’s discovery directory to your canonical source. It’s idempotent — safe to re-run any time, including on every new machine.

### 4. Add a new skill

```bash
mkdir -p ~/your-repo/skills/my-skill
# create ~/your-repo/skills/my-skill/SKILL.md
bash ~/.claude/skills/canonical-skills-setup/scripts/bootstrap.sh ~/your-repo/skills
```

## What’s in this repo

```
skills/
  canonical-skills-setup/
    SKILL.md              ← the /canonical-skills-setup slash command
    scripts/
      bootstrap.sh        ← symlink wiring script
```

## Built on

- [agentskills.io](https://agentskills.io) — the open Agent Skills standard

## License

MIT
