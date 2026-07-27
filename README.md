# lark-push

Push concise Feishu / Lark notifications from any coding agent.

Works with Claude Code, Codex, Cursor, OpenCode, and [70+ agents](https://github.com/vercel-labs/skills#supported-agents) via the [skills CLI](https://skills.sh/).

[![skills.sh](https://skills.sh/b/kedoupi/lark-push)](https://skills.sh/kedoupi/lark-push)

## Install

```bash
# Global (all projects)
npx skills add kedoupi/lark-push -g --all

# Project-level
npx skills add kedoupi/lark-push --all

# Specific agents only
npx skills add kedoupi/lark-push -g -a claude-code -a codex -a cursor -y
```

List skills in this repo without installing:

```bash
npx skills add kedoupi/lark-push --list
```

## Prerequisites

1. [lark-cli](https://github.com/larksuite/cli) installed and authenticated
2. A Feishu / Lark bot (or user identity) that can send messages to your target chat
3. Target chat id (`oc_xxx`)

```bash
# Verify auth
LARKSUITE_CLI_NO_UPDATE_NOTIFIER=1 LARKSUITE_CLI_NO_SKILLS_NOTIFIER=1 \
  lark-cli auth status --json --verify
```

## Configuration

Set the default target chat (required unless you always pass `--chat-id`):

```bash
export LARK_PUSH_CHAT_ID="oc_xxxxxxxx"
```

Optional:

| Variable | Default | Description |
| --- | --- | --- |
| `LARK_PUSH_CHAT_ID` | _(empty)_ | Default group / chat id |
| `LARK_PUSH_AS` | `bot` | Send as `bot` or `user` |
| `LARK_PUSH_FOOTER` | `via lark-push` | Card footer caption |
| `LARK_PUSH_CONFIG` | `~/.config/lark-push/config.env` | Optional env file auto-loaded if present |

Example config file:

```bash
# ~/.config/lark-push/config.env
LARK_PUSH_CHAT_ID=oc_xxxxxxxx
LARK_PUSH_AS=bot
LARK_PUSH_FOOTER=via my-team bot
```

## Usage

After install, the skill lives under your agent skills directory, for example:

- `~/.agents/skills/lark-push/`
- `~/.codex/skills/lark-push/`
- `~/.claude/skills/lark-push/`
- `./.agents/skills/lark-push/` (project scope)

```bash
# Preview
scripts/lark-push \
  --dry-run \
  --kind code \
  --title "Code task complete" \
  --body "Implementation done. Local tests passed."

# Daily report from stdin
cat daily.md | scripts/lark-push --kind daily --title "Daily report"

# Weekly report from file
scripts/lark-push \
  --kind weekly \
  --title "Weekly report" \
  --from-file weekly.md

# Override target chat for one send
scripts/lark-push \
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

## Git post-commit hook (optional)

```bash
# From a git repo root
ln -sf "$(pwd)/path/to/skills/lark-push/scripts/git-post-commit-lark-push" \
  .git/hooks/post-commit
```

Ensure `LARK_PUSH_CHAT_ID` is available in your shell environment (or config file) before committing.

## Agent safety

Messages are visible in the group. Agents should confirm:

- recipient chat
- message content
- sending identity (`bot` / `user`)

Use `--dry-run` for previews. Running the helper script yourself counts as approval.

## Repository layout

```text
skills/
  lark-push/
    SKILL.md
    scripts/
      lark-push
      git-post-commit-lark-push
    templates/
      daily.md
      weekly.md
```

Compatible with `npx skills add <owner/repo>` discovery (skills under `skills/`).

## License

MIT
