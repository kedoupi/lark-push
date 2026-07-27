# lark-push

Push concise Feishu / Lark notifications from any coding agent.

Works with Claude Code, Codex, Cursor, OpenCode, and [70+ agents](https://github.com/vercel-labs/skills#supported-agents) via the [skills CLI](https://skills.sh/).

[![skills.sh](https://skills.sh/b/kedoupi/lark-push)](https://skills.sh/kedoupi/lark-push)

## Install

```bash
# Global, all agents (symlink mode recommended)
npx skills add kedoupi/lark-push -g --all

# Project-level
npx skills add kedoupi/lark-push --all

# Specific agents only
npx skills add kedoupi/lark-push -g -a claude-code -a codex -a cursor -y

# Copy mode instead of symlink
npx skills add kedoupi/lark-push -g --all --copy
```

List without installing:

```bash
npx skills add kedoupi/lark-push --list
```

## How skills install modes affect config

| Mode | Layout | Config strategy |
| --- | --- | --- |
| **symlink** (default) | Canonical package at `~/.agents/skills/lark-push/`; agents symlink to it | Write **one** durable config next to that canonical package |
| **copy** | Independent full copy per agent | Each agent has its own durable config **or** use `--target global` once |

`npx skills update` deletes and re-copies the skill package directory.  
Therefore local secrets/settings must **not** live only inside the package.

### Durable config (recommended)

Config follows the **skills parent directory**, as a sibling of the package:

```text
~/.agents/skills/
  lark-push/                         # skill package (wiped on update)
  .skill-data/
    lark-push/
      config.env                     # durable config (kept on update)
```

After install:

```bash
# Typical global symlink install
bash ~/.agents/skills/lark-push/scripts/lark-push init --chat-id oc_xxxxxxxx

# Optional footer / identity
bash ~/.agents/skills/lark-push/scripts/lark-push init \
  --chat-id oc_xxxxxxxx \
  --as bot \
  --footer "via my bot"

# Shared config when using copy mode across many agents
bash ~/.agents/skills/lark-push/scripts/lark-push init \
  --target global \
  --chat-id oc_xxxxxxxx
```

Inspect:

```bash
bash ~/.agents/skills/lark-push/scripts/lark-push config-path
bash ~/.agents/skills/lark-push/scripts/lark-push which-config
```

### Load order (later wins)

1. `~/.config/lark-push/config.env` (legacy)
2. `~/.agents/skills/.skill-data/lark-push/config.env` (shared global)
3. `<skills-parent>/.skill-data/lark-push/config.env` (install-local durable)
4. `<skill-root>/config.local.env` (in-package; **wiped by update**)
5. `$LARK_PUSH_CONFIG`
6. CLI flags

| Variable | Default | Description |
| --- | --- | --- |
| `LARK_PUSH_CHAT_ID` | _(required)_ | Target chat id |
| `LARK_PUSH_AS` | `bot` | `bot` or `user` |
| `LARK_PUSH_FOOTER` | `via lark-push` | Card footer |
| `LARK_PUSH_CONFIG` | _(unset)_ | Explicit env file path |

## Prerequisites

1. [lark-cli](https://github.com/larksuite/cli) installed and authenticated
2. Bot/user allowed to send messages to the target chat
3. `lark-push init` completed (or env/flags provided)

```bash
LARKSUITE_CLI_NO_UPDATE_NOTIFIER=1 LARKSUITE_CLI_NO_SKILLS_NOTIFIER=1 \
  lark-cli auth status --json --verify
```

## Usage

```bash
# Preview
bash ~/.agents/skills/lark-push/scripts/lark-push \
  --dry-run \
  --kind code \
  --title "Code task complete" \
  --body "Implementation done. Local tests passed."

# Daily report from stdin
cat daily.md | bash ~/.agents/skills/lark-push/scripts/lark-push \
  --kind daily \
  --title "Daily report"

# Weekly report from file
bash ~/.agents/skills/lark-push/scripts/lark-push \
  --kind weekly \
  --title "Weekly report" \
  --from-file weekly.md

# One-off override
bash ~/.agents/skills/lark-push/scripts/lark-push \
  --chat-id oc_other \
  --kind notice \
  --title "Heads up" \
  --body "Release window starts in 30 minutes."
```

### Message kinds

| Kind | Use for |
| --- | --- |
| `code` | code completion, test result, PR / release status |
| `daily` | daily standup report |
| `weekly` | weekly report |
| `release` | deployment or launch note |
| `notice` | general message |

### Formats

| Format | Use for |
| --- | --- |
| `card` | default; Feishu Card 2.0 interactive card |
| `markdown` | lightweight markdown post |

## Why not only put config inside the skill folder?

Because skills install/update does this for the package dir:

1. delete skill directory
2. copy fresh files from the repo

So in-package `config.env` is convenient for a quick test, but disappears on update.  
Sibling `.skill-data/` keeps the mental model of “follows this skill install” without being wiped.

`npx skills add` also has **no post-install hook**, so config cannot be written automatically during install.  
`lark-push init` is the intentional setup step.

## Git post-commit hook (optional)

```bash
ln -sf ~/.agents/skills/lark-push/scripts/git-post-commit-lark-push \
  .git/hooks/post-commit
```

Ensure durable config exists first (`lark-push init`).

## Agent safety

Messages are visible in the group. Agents should confirm:

- recipient chat
- message content
- sending identity (`bot` / `user`)

Use `--dry-run` for previews. Running the helper yourself counts as approval.

## Repository layout

```text
skills/
  lark-push/
    SKILL.md
    config.example.env
    scripts/
      lark-push
      git-post-commit-lark-push
    templates/
      daily.md
      weekly.md
```

## License

MIT
