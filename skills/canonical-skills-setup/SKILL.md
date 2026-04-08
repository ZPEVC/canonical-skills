---
name: canonical-skills-setup
description: One-time migration to consolidate scattered agent skills into a single version-controlled repo. Use when setting up on a new machine, consolidating existing skills, or onboarding to a centralized skills workflow.
argument-hint: [github-org]
disable-model-invocation: true
---

# Canonical Skills Setup

A one-time migration that consolidates scattered agent skills into a single GitHub repo, then hands off to `npx skills` for ongoing management.

## Step 1: Scan for existing skills

Run the migration scanner to find all skills across agent directories:

```!
bash ${CLAUDE_SKILL_DIR}/scripts/migrate.sh scan
```

Review the output. It will show:
- Which skills were found in each agent directory
- Whether each skill is **user-created** or **npx-managed** (from `.skill-lock.json`)
- Any duplicates across agents

Present the results to the user as a table.

## Step 2: Ask the user about their repo

Ask the user:

> "I found **N** user-created skills across your agent directories. These need a single home — a GitHub repo that becomes your canonical source."
>
> **Do you already have a repo for your skills?**
> 1. Yes — provide the org/repo name
> 2. No — I'll help you create one

If they need a new repo:
- Ask which GitHub org to use (or personal account)
- Create a public repo named `agent-skills` under their org using the GitHub MCP tool
- Initialize it with a README

## Step 3: Consolidate skills

Run the migration to collect user-created skills into a local staging directory:

```!
bash ${CLAUDE_SKILL_DIR}/scripts/migrate.sh collect /tmp/skills-migration
```

Review the collected skills with the user. Ask if any should be excluded (experimental, outdated, or private skills they don't want in a repo).

## Step 4: Push to GitHub

Push the approved skills to their repo using the GitHub MCP `push_files` tool. Structure them as:

```
skills/
  skill-name/
    SKILL.md
    (any supporting files)
```

## Step 5: Install globally via npx skills

Now that the canonical repo exists on GitHub, install it:

```bash
npx skills add -g <org>/<repo> --all
```

This will:
- Clone the repo to a cache
- Symlink every skill to every agent's discovery directory
- Track everything in `.skill-lock.json`

## Step 6: Clean up old locations

The original scattered copies are now redundant. Offer to remove them:
- User-created skills in `~/.gemini/antigravity/skills/` that are now in the repo
- Duplicates in `~/.agents/skills/` that `npx skills` has replaced with symlinks
- Project-level copies in `.github/skills/` that are now canonical

**Do NOT remove npx-managed skills** (ones tracked in `.skill-lock.json` from third-party repos like `google-labs-code/stitch-skills`).

## Step 7: Confirm

Verify setup by asking the user to:
1. Restart their agent clients
2. Run `/skills` or equivalent in each agent
3. Confirm all skills appear

Report:
> "Migration complete. **N** skills consolidated into `org/repo`. From here, use `npx skills` to manage them:
> - `npx skills update` — pull latest from your repo
> - `npx skills add -g org/repo --all` — reinstall on a new machine
> - `npx skills list` — see what's installed"

## Related

- [agentskills.io](https://agentskills.io) — the open Agent Skills standard
- [npx skills CLI](https://www.npmjs.com/package/skills) — ongoing skill management
