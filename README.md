# canonical-skills

A one-time migration tool that consolidates scattered agent skills into a single GitHub repo, then hands off to [`npx skills`](https://www.npmjs.com/package/skills) for ongoing management.

## The problem

If you use multiple AI agents (Claude Code, Gemini CLI, VS Code Copilot, etc.), your skills end up scattered:

```
~/.claude/skills/my-skill/SKILL.md        ← copy 1
~/.agents/skills/my-skill/SKILL.md        ← copy 2
~/.gemini/antigravity/skills/my-skill/    ← copy 3
```

They drift out of sync. You forget which version is current. Switching machines means starting over.

## The solution

Run `/canonical-skills-setup` once. It will:

1. **Scan** all agent directories for existing skills
2. **Separate** user-created skills from npx-managed ones
3. **Help you create** a GitHub repo (or use an existing one)
4. **Consolidate** your skills into that repo
5. **Install globally** via `npx skills add -g your-org/your-repo --all`
6. **Clean up** the old scattered copies

After that, `npx skills` handles everything — updates, installs on new machines, distribution.

## Quick start

```bash
# Install the migration skill
npx skills add -g ZPEVC/canonical-skills

# Run it in any agent that supports skills
/canonical-skills-setup
```

Or run the scanner directly:

```bash
# See what you've got scattered around
bash ~/.claude/skills/canonical-skills-setup/scripts/migrate.sh scan
```

## What’s in this repo

```
skills/
  canonical-skills-setup/
    SKILL.md              ← the /canonical-skills-setup onboarding flow
    scripts/
      migrate.sh          ← scanner and collector script
```

## After migration

Once your skills are consolidated, you don't need this tool anymore. Use `npx skills` for everything:

```bash
npx skills list                              # see installed skills
npx skills update                            # pull latest from your repo
npx skills add -g your-org/your-repo --all   # reinstall on a new machine
```

## Built on

- [agentskills.io](https://agentskills.io) — the open Agent Skills standard

## License

MIT
