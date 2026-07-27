---
name: lark-push
description: Use when the user asks to send Feishu or Lark push notifications, code completion notices, daily reports, weekly reports, release summaries, or progress updates to a configured group chat.
metadata:
  author: kedoupi
  version: "1.0.0"
  requires:
    bins: ["lark-cli"]
---

# Lark Push

Send concise Feishu / Lark messages through `lark-cli`. Default output is a Card 2.0 interactive card; use `--format markdown` for plain formatted text.

## Prerequisites

1. `lark-cli` installed and authenticated
2. Bot or user identity allowed to post in the target chat
3. Target chat id via `LARK_PUSH_CHAT_ID` or `--chat-id`

```bash
LARKSUITE_CLI_NO_UPDATE_NOTIFIER=1 LARKSUITE_CLI_NO_SKILLS_NOTIFIER=1 \
  lark-cli auth status --json --verify
```

Optional config file (auto-loaded if present):

```bash
# ~/.config/lark-push/config.env
LARK_PUSH_CHAT_ID=oc_xxxxxxxx
LARK_PUSH_AS=bot
LARK_PUSH_FOOTER=via lark-push
```

## Safety

Messages are visible in the group. Before an agent sends a real message, confirm:

- recipient group or person (`chat-id`)
- message content
- sending identity (`bot` / `user`)

If the user runs the helper script directly, that invocation is the approval. For agent-side previews, use `--dry-run`.

## Helper

Resolve the skill directory first (agent install path varies), then run:

```bash
# Preview a code completion notice
bash <skill-dir>/scripts/lark-push \
  --dry-run \
  --format card \
  --kind code \
  --title "Code task complete" \
  --body "Implementation finished. Local verification passed."

# Send a daily report from stdin
cat daily.md | bash <skill-dir>/scripts/lark-push \
  --kind daily \
  --title "Daily report"

# Send a weekly report from a file
bash <skill-dir>/scripts/lark-push \
  --format card \
  --kind weekly \
  --title "Weekly report" \
  --from-file weekly.md
```

Common install locations:

- Global: `~/.agents/skills/lark-push/`, `~/.codex/skills/lark-push/`, `~/.claude/skills/lark-push/`
- Project: `./.agents/skills/lark-push/`, `./.codex/skills/lark-push/`, `./.claude/skills/lark-push/`

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

Daily report body:

```text
Today:
- 

Blockers:
- 

Tomorrow:
- 
```

Weekly report body:

```text
Focus:
- 

Progress:
- 

Risks / next week:
- 
```

Ready-made files live in `templates/daily.md` and `templates/weekly.md`.

## Options reference

```text
--kind <code|daily|weekly|release|notice>
--format <card|markdown>     Default: card
--title <text>
--body <text>
--from-file <path>
--chat-id <oc_xxx>           Override LARK_PUSH_CHAT_ID
--as <bot|user>              Default: bot (or LARK_PUSH_AS)
--idempotency-key <key>
--dry-run
--no-context                 Skip repo/branch context footer fields
```

## Troubleshooting

Auth / bot readiness:

```bash
LARKSUITE_CLI_NO_UPDATE_NOTIFIER=1 LARKSUITE_CLI_NO_SKILLS_NOTIFIER=1 \
  lark-cli auth status --json --verify
```

If send fails:

1. Confirm `LARK_PUSH_CHAT_ID` / `--chat-id` is correct
2. Confirm the bot is in the target group and can send messages
3. Confirm `lark-cli` scopes cover IM message send
