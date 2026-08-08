---
name: lark-push
description: Use when the user asks to send Feishu or Lark push notifications, code completion notices, daily reports, weekly reports, release summaries, or progress updates to a configured group chat.
metadata:
  author: kedoupi
  version: "1.3.0"
  requires:
    bins: ["lark-cli"]
---

# Lark Push

Send concise Feishu / Lark messages through `lark-cli`. Default output is a Card 2.0 interactive card; use `--format markdown` for plain formatted text.

## Prerequisites (agents: check these first)

If anything is missing, **tell the user how to install it** — do not assume Node or `lark-cli` exist.

Run the built-in checklist:

```bash
bash <skill-dir>/scripts/lark-push doctor
```

| Need | Why | If missing |
| --- | --- | --- |
| **Node.js + npm** | `npx skills add …`; typical way to install `lark-cli` | Install LTS from https://nodejs.org/ or `brew install node` |
| **lark-cli** | Actually send messages to Feishu/Lark | `npm install -g @larksuite/cli` then `lark-cli config init` / `auth status` |
| **python3** | Default Card 2.0 (`--format card`) | `brew install python3`, or use `--format markdown` |
| **Skill config** | Target chat id | `bash <skill-dir>/scripts/lark-push init --chat-id oc_xxx` |

Suggested order for a new machine:

```bash
# 1) Node (if needed)
#    https://nodejs.org/  or  brew install node

# 2) Install this skill
npx skills add kedoupi/lark-push -g --all

# 3) Feishu CLI
npm install -g @larksuite/cli
lark-cli config init --help
LARKSUITE_CLI_NO_UPDATE_NOTIFIER=1 LARKSUITE_CLI_NO_SKILLS_NOTIFIER=1 \
  lark-cli auth status --json --verify

# 4) Skill chat config
bash <skill-dir>/scripts/lark-push init --chat-id oc_xxxxxxxx

# 5) Verify
bash <skill-dir>/scripts/lark-push doctor
```

On macOS, if `lark-cli` reports **keychain access blocked** inside an Agent, run once in **Terminal.app**:

```bash
lark-cli config keychain-downgrade
```

## Locating the helper

The skill may be installed via symlink or copy. Resolve the real path:

```bash
# Common locations:
#   Canonical / symlink source: ~/.agents/skills/lark-push/
#   Claude:  ~/.claude/skills/lark-push/
#   Codex:   ~/.codex/skills/lark-push/
#   Project: ./.agents/skills/lark-push/
```

The script uses `pwd -P` internally, so symlinks resolve to the real directory and share one durable config.

## Config

One-time after install:

```bash
bash <skill-dir>/scripts/lark-push init --chat-id oc_xxxxxxxx
```

Config is stored **outside** the skill package (survives `npx skills update`).
See the [online docs](https://github.com/kedoupi/lark-push#readme) for the full config layout, load order, and install-mode differences.

Inspect:

```bash
bash <skill-dir>/scripts/lark-push doctor
bash <skill-dir>/scripts/lark-push config-path
bash <skill-dir>/scripts/lark-push which-config
```

## Safety

Messages are visible in the group. Before sending a real message, confirm:

- recipient group or person (`chat-id`)
- message content
- sending identity (`bot` / `user`)

If the user runs the helper script directly, that invocation is the approval.
For previews, use `--dry-run` (local only — does **not** call `lark-cli` or touch the keychain).

## Usage

```bash
# Environment check (print install hints if something is missing)
bash <skill-dir>/scripts/lark-push doctor

# Preview (local; no network / no keychain)
bash <skill-dir>/scripts/lark-push --dry-run --kind code --title "Task done" --body "Implementation finished."

# Markdown list body (leading '-' is valid)
bash <skill-dir>/scripts/lark-push --dry-run --kind daily --title "Daily" --body "- shipped A
- blocked on B"

# Daily report from stdin
cat daily.md | bash <skill-dir>/scripts/lark-push --kind daily --title "Daily report"

# Weekly report from file
bash <skill-dir>/scripts/lark-push --kind weekly --title "Weekly report" --from-file weekly.md

# One-off chat override
bash <skill-dir>/scripts/lark-push --chat-id oc_other --kind notice --title "Heads up" --body "..."
```

## Message kinds

| Kind | Use for |
| --- | --- |
| `code` | code completion, test result, PR/release status |
| `daily` | daily standup report |
| `weekly` | weekly report |
| `release` | deployment or launch note |
| `notice` | general message |

## Output formats

| Format | Use for |
| --- | --- |
| `card` | default; polished Feishu Card 2.0 (requires `python3`) |
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

## Key CLI options

```text
doctor [--strict-auth]        # environment checklist + install hints
--kind <code|daily|weekly|release|notice>
--format <card|markdown>
--title <text>
--body <text>
--from-file <path>
--chat-id <oc_xxx>
--as <bot|user>
--idempotency-key <key>   # max 50 chars
--dry-run                 # local preview only
--no-context
```

Full reference: `bash <skill-dir>/scripts/lark-push --help` or see the [online docs](https://github.com/kedoupi/lark-push#readme).

## Optional: git post-commit hook

Prefer a **symlink** (not a copy) so the hook can find the helper:

```bash
ln -sf ~/.agents/skills/lark-push/scripts/git-post-commit-lark-push \
  .git/hooks/post-commit
```

Disable without removing the hook:

```bash
export LARK_PUSH_GIT_HOOK=0
```

## Troubleshooting

```bash
bash <skill-dir>/scripts/lark-push doctor
```

If send fails:

1. Run `doctor` and fix any `[FAIL]` lines (Node, lark-cli, python3, chat id)
2. Confirm durable config: `bash <skill-dir>/scripts/lark-push which-config`
3. Confirm the bot is in the target group and can send messages
4. Confirm `lark-cli` auth / scopes:

```bash
LARKSUITE_CLI_NO_UPDATE_NOTIFIER=1 LARKSUITE_CLI_NO_SKILLS_NOTIFIER=1 \
  lark-cli auth status --json --verify
```
