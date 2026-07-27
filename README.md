# lark-push

[English](./README.md) | [简体中文](./README.zh-CN.md)

Push concise **Feishu / Lark** notifications from coding agents.

Works with Claude Code, Codex, Cursor, OpenCode, Grok Build, and [70+ agents](https://github.com/vercel-labs/skills#supported-agents) via the [skills CLI](https://skills.sh/).

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
[![skills.sh](https://skills.sh/b/kedoupi/lark-push)](https://skills.sh/kedoupi/lark-push)
[![GitHub](https://img.shields.io/badge/GitHub-kedoupi%2Flark--push-181717?logo=github)](https://github.com/kedoupi/lark-push)

<p align="center">
  <img src="docs/screenshots/daily-project.png" alt="Project daily report card in Feishu" width="420" />
</p>

## Why this skill?

Coding agents finish work in a terminal. Teams still coordinate in **Feishu / Lark**.  
`lark-push` bridges that gap: when a task, daily summary, or release is done, the agent posts a clean Card 2.0 message into your project group—without opening the Feishu app or writing ad-hoc API code.

## Primary use cases

| Scenario | Kind | When to use |
| --- | --- | --- |
| **Code task done** | `code` | Implementation finished, tests passed, PR opened / merged |
| **Daily standup report** | `daily` | End of day: what shipped, blockers, next steps |
| **Feature / sprint digest** | `daily` or `weekly` | A focused slice (e.g. one product line) summarized for the group |
| **Weekly report** | `weekly` | Week focus, progress, risks, next week plan |
| **Release / deploy note** | `release` | Version shipped, env, rollback notes |
| **Ops / setup notice** | `notice` | Skill installed, config changed, heads-up messages |
| **Post-commit notify** (optional) | `code` | Auto ping after local commits via git hook |

Typical flow:

```text
Agent finishes work
    → lark-push builds Card 2.0 (title, type, time, repo context, body)
    → 建国 / your bot posts to the project group
    → Teammates see progress without asking "is it done?"
```

## Screenshots

Real messages posted to a Feishu group (Card 2.0).

### Project daily report

End-of-day multi-workstream summary for the whole monorepo.

![Project daily report](docs/screenshots/daily-project.png)

### Feature daily report

Focused daily for one product track (progress, verification, PR, remaining gates).

![Feature daily report](docs/screenshots/daily-feature.png)

### Setup / ops notice

One-off notice after installing and configuring the skill on a machine.

![Install notice](docs/screenshots/notice-install.png)

## Features

- One command install for multi-agent environments: `npx skills add kedoupi/lark-push`
- Card 2.0 interactive messages (default) or lightweight markdown
- Message kinds: `code` / `daily` / `weekly` / `release` / `notice`
- Config follows the skill install tree and **survives** `npx skills update`
- Optional git post-commit hook
- Built on official [`lark-cli`](https://github.com/larksuite/cli)

## Install

```bash
# Global (recommended): install for all supported agents
npx skills add kedoupi/lark-push -g --all

# Project-level
npx skills add kedoupi/lark-push --all

# Specific agents only
npx skills add kedoupi/lark-push -g -a claude-code -a codex -a cursor -y

# Copy mode instead of symlink
npx skills add kedoupi/lark-push -g --all --copy
```

List skills without installing:

```bash
npx skills add kedoupi/lark-push --list
```

Browse on [skills.sh](https://skills.sh/kedoupi/lark-push).

## Prerequisites

1. [`lark-cli`](https://github.com/larksuite/cli) installed and authenticated
2. A Feishu/Lark bot (or user identity) that can post to your target chat
3. Target chat id (`oc_xxx`)

```bash
LARKSUITE_CLI_NO_UPDATE_NOTIFIER=1 LARKSUITE_CLI_NO_SKILLS_NOTIFIER=1 \
  lark-cli auth status --json --verify
```

## Quick start

```bash
# 1) One-time config after install (durable, update-safe)
bash ~/.agents/skills/lark-push/scripts/lark-push init --chat-id oc_xxxxxxxx

# Optional identity / footer
bash ~/.agents/skills/lark-push/scripts/lark-push init \
  --chat-id oc_xxxxxxxx \
  --as bot \
  --footer "via my bot" \
  --force

# 2) Preview
bash ~/.agents/skills/lark-push/scripts/lark-push \
  --dry-run \
  --kind code \
  --title "Code task complete" \
  --body "Implementation done. Local tests passed."

# 3) Send
bash ~/.agents/skills/lark-push/scripts/lark-push \
  --kind code \
  --title "Code task complete" \
  --body "Implementation done. Local tests passed."
```

## Configuration

### Why not put config only inside the skill package?

`npx skills update` **deletes and re-copies** the skill package directory.  
Local settings must live outside that package.

### Durable path (recommended)

Config is stored next to the skill install:

```text
~/.agents/skills/
  lark-push/                 # skill package (wiped on update)
  .skill-data/
    lark-push/
      config.env             # durable local config (kept on update)
```

### Install modes

| Mode | Layout | Config |
| --- | --- | --- |
| **symlink** (default) | Canonical package at `~/.agents/skills/lark-push/`; agents symlink to it | One durable config serves all agents |
| **copy** (`--copy`) | Full copy per agent | Per-agent durable config, or `--target global` once |

### Load order (later wins)

1. `~/.config/lark-push/config.env` (legacy)
2. `~/.agents/skills/.skill-data/lark-push/config.env` (shared global)
3. `<skills-parent>/.skill-data/lark-push/config.env` (install-local durable)
4. `<skill-root>/config.local.env` (in-package; wiped by update)
5. `$LARK_PUSH_CONFIG`
6. CLI flags

| Variable | Default | Description |
| --- | --- | --- |
| `LARK_PUSH_CHAT_ID` | _(required)_ | Target chat id |
| `LARK_PUSH_AS` | `bot` | `bot` or `user` |
| `LARK_PUSH_FOOTER` | `via lark-push` | Card footer caption |
| `LARK_PUSH_CONFIG` | _(unset)_ | Explicit env file path |

Inspect:

```bash
bash ~/.agents/skills/lark-push/scripts/lark-push config-path
bash ~/.agents/skills/lark-push/scripts/lark-push which-config
```

## Usage

```bash
# Daily report from stdin
cat daily.md | bash ~/.agents/skills/lark-push/scripts/lark-push \
  --kind daily \
  --title "Daily report"

# Weekly report from file
bash ~/.agents/skills/lark-push/scripts/lark-push \
  --kind weekly \
  --title "Weekly report" \
  --from-file weekly.md

# One-off chat override
bash ~/.agents/skills/lark-push/scripts/lark-push \
  --chat-id oc_other \
  --kind notice \
  --title "Heads up" \
  --body "Release window starts in 30 minutes."
```

### Message kinds

| Kind | Use for |
| --- | --- |
| `code` | code completion, tests, PR / release status |
| `daily` | daily standup report |
| `weekly` | weekly report |
| `release` | deployment or launch note |
| `notice` | general message |

### Formats

| Format | Use for |
| --- | --- |
| `card` | default; Feishu Card 2.0 |
| `markdown` | lightweight markdown post |

### CLI options

```text
--kind <code|daily|weekly|release|notice>
--format <card|markdown>
--title <text>
--body <text>
--from-file <path>
--chat-id <oc_xxx>
--as <bot|user>
--idempotency-key <key>
--dry-run
--no-context
```

## Optional: git post-commit hook

```bash
ln -sf ~/.agents/skills/lark-push/scripts/git-post-commit-lark-push \
  .git/hooks/post-commit
```

Run `lark-push init` first so chat id is available.

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
    SKILL.md                 # agent skill definition
    config.example.env
    scripts/
      lark-push              # main CLI
      git-post-commit-lark-push
    templates/
      daily.md
      weekly.md
docs/
  screenshots/               # Feishu card screenshots used in README
README.md                    # English (default)
README.zh-CN.md              # Chinese
LICENSE
```

Compatible with `npx skills add <owner/repo>` discovery.

## Development

```bash
git clone https://github.com/kedoupi/lark-push.git
cd lark-push

# List discoverable skills from local path
npx skills add ./ --list

# Install from local checkout
npx skills add ./ -g --all -y

# Dry-run helper
bash skills/lark-push/scripts/lark-push \
  --dry-run \
  --chat-id oc_example \
  --kind code \
  --title "Test" \
  --body "hello"
```

See [AGENTS.md](./AGENTS.md) for contributor guidance when editing this repo with coding agents.

## Troubleshooting

```bash
# Auth
LARKSUITE_CLI_NO_UPDATE_NOTIFIER=1 LARKSUITE_CLI_NO_SKILLS_NOTIFIER=1 \
  lark-cli auth status --json --verify

# Effective config
bash ~/.agents/skills/lark-push/scripts/lark-push which-config
```

If send fails:

1. Confirm durable config exists and chat id is correct
2. Confirm the bot is in the target group and can send messages
3. Confirm `lark-cli` scopes cover IM message send

## License

[MIT](./LICENSE)

## Links

- GitHub: https://github.com/kedoupi/lark-push
- skills.sh: https://skills.sh/kedoupi/lark-push
- skills CLI: https://github.com/vercel-labs/skills
- lark-cli: https://github.com/larksuite/cli
