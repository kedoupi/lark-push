---
name: lark-push
description: Use when the user asks to send Feishu or Lark push notifications, code completion notices, daily reports, weekly reports, release summaries, or progress updates to a configured group chat.
metadata:
  author: kedoupi
  version: "1.1.0"
  requires:
    bins: ["lark-cli"]
---

# Lark Push

Send concise Feishu / Lark messages through `lark-cli`. Default output is a Card 2.0 interactive card; use `--format markdown` for plain formatted text.

## Prerequisites

1. `lark-cli` installed and authenticated
2. Bot or user identity allowed to post in the target chat
3. Local config created once after install (chat id)

```bash
LARKSUITE_CLI_NO_UPDATE_NOTIFIER=1 LARKSUITE_CLI_NO_SKILLS_NOTIFIER=1 \
  lark-cli auth status --json --verify
```

## Config (follows skill install location)

`npx skills` has two install modes:

| Mode | What happens | Config implication |
| --- | --- | --- |
| **symlink** (default) | Real files live in `~/.agents/skills/lark-push/`; agents get symlinks | One durable config serves all agents |
| **copy** (`--copy`) | Full copy into each agent skills dir | Each agent tree has its own durable config, or use shared global path |

Important: `npx skills update` **wipes and re-copies the skill package directory**.  
So config must **not** live only inside the package.

### Recommended durable path

Sibling data dir next to the skill package:

```text
<skills-parent>/
  lark-push/                         # skill package (wiped on update)
  .skill-data/
    lark-push/
      config.env                     # durable local config (kept on update)
```

Examples:

- Global symlink install: `~/.agents/skills/.skill-data/lark-push/config.env`
- Project install: `./.agents/skills/.skill-data/lark-push/config.env`
- Copy into Claude only: `~/.claude/skills/.skill-data/lark-push/config.env`

### One-time setup after install

```bash
# Resolve installed skill path first, then:
bash <skill-dir>/scripts/lark-push init --chat-id oc_xxxxxxxx

# Optional:
bash <skill-dir>/scripts/lark-push init \
  --chat-id oc_xxxxxxxx \
  --as bot \
  --footer "via my bot"

# Shared config for copy-mode multi-agent:
bash <skill-dir>/scripts/lark-push init --target global --chat-id oc_xxxxxxxx
```

Inspect:

```bash
bash <skill-dir>/scripts/lark-push config-path
bash <skill-dir>/scripts/lark-push which-config
```

### Load order (later overrides earlier)

1. `~/.config/lark-push/config.env` (legacy)
2. `~/.agents/skills/.skill-data/lark-push/config.env` (shared global)
3. `<skills-parent>/.skill-data/lark-push/config.env` (install-local durable)
4. `<skill-root>/config.local.env` (in-package; wiped by update)
5. `$LARK_PUSH_CONFIG` explicit file
6. CLI flags (`--chat-id`, `--as`, ...)

## Safety

Messages are visible in the group. Before an agent sends a real message, confirm:

- recipient group or person (`chat-id`)
- message content
- sending identity (`bot` / `user`)

If the user runs the helper script directly, that invocation is the approval. For agent-side previews, use `--dry-run`.

## Helper

```bash
# Preview
bash <skill-dir>/scripts/lark-push \
  --dry-run \
  --format card \
  --kind code \
  --title "Code task complete" \
  --body "Implementation finished. Local verification passed."

# Daily report from stdin
cat daily.md | bash <skill-dir>/scripts/lark-push \
  --kind daily \
  --title "Daily report"

# Weekly report from file
bash <skill-dir>/scripts/lark-push \
  --kind weekly \
  --title "Weekly report" \
  --from-file weekly.md
```

Common install locations:

- Canonical / symlink source: `~/.agents/skills/lark-push/`
- Codex symlink/copy: `~/.codex/skills/lark-push/`
- Claude symlink/copy: `~/.claude/skills/lark-push/`
- Project: `./.agents/skills/lark-push/`

Script uses `pwd -P`, so symlink installs resolve to the real skill root and share one durable config.

## Message Kinds

| Kind | Use for |
| --- | --- |
| `code` | code completion, test result, PR/release status |
| `daily` | daily report |
| `weekly` | weekly report |
| `release` | deployment or launch note |
| `notice` | general message |

## Output Formats

| Format | Use for |
| --- | --- |
| `card` | default; polished Feishu Card 2.0 |
| `markdown` | lightweight text post |

## Templates

Code update body:

```text
Done:
- 

Verification:
- 

Risks / next:
- 
```

Daily / weekly templates: `templates/daily.md`, `templates/weekly.md`.

## Options reference

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

## Troubleshooting

```bash
LARKSUITE_CLI_NO_UPDATE_NOTIFIER=1 LARKSUITE_CLI_NO_SKILLS_NOTIFIER=1 \
  lark-cli auth status --json --verify

bash <skill-dir>/scripts/lark-push which-config
```

If send fails:

1. Confirm durable config exists and chat id is correct
2. Confirm the bot is in the target group
3. Confirm `lark-cli` scopes cover IM message send
