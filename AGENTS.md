# AGENTS.md

Guidance for **any** AI coding agent working in this repository
(Claude Code, Codex, Cursor, Grok Build, …).

This file is the **source of truth**. Optional `CLAUDE.md` only points here.

## Purpose

This repo publishes one installable agent skill: `lark-push`.

Users install it with:

```bash
npx skills add kedoupi/lark-push-skill
```

## Layout

```text
skills/
  lark-push/           # installable package (skills CLI)
    SKILL.md
    scripts/
      lark-push
      build_card.py
      git-post-commit-lark-push
    templates/
docs/
  README.md
  screenshots/         # curated gallery
tests/
  README.md
  run.sh               # offline self-test (no keychain / network)
```

**docs / tests / artifacts:** guides + gallery under `docs/`; offline CI under `tests/`; generated dumps would go under `artifacts/` (none for this skill yet). Incubator SoT: `schema/skill-repo.md`.

## Editing rules

- Keep `SKILL.md` under ~500 lines; put long references in separate files.
- Do not hardcode private chat ids, tokens, or team-specific bot names.
- Require `LARK_PUSH_CHAT_ID` or `--chat-id` for real sends.
- Scripts must resolve their own directory and work after install to any agent path.
- Prefer bash + `lark-cli`; avoid extra runtime dependencies beyond `python3` for JSON card build.
- Bump `metadata.version` in `SKILL.md` when behavior changes (`--version` reads it).
- `--dry-run` must stay **local** (no `lark-cli` call).
- CLI values may start with `-` (markdown lists); do not reject `-*` as “missing”.
- Missing deps must print install hints (`doctor`, `require_lark_cli`, Node/npm guidance).

## Config design

- Do **not** store secrets only inside the skill package: `npx skills update` wipes that directory.
- Durable config lives at `<skills-parent>/.skill-data/lark-push/config.env`.
- After install users run `bash scripts/lark-push init --chat-id oc_xxx`.
- `npx skills add` has no post-install hook; init is intentional.

## Local validation

```bash
bash tests/run.sh

# Environment checklist (install hints when deps missing)
bash skills/lark-push/scripts/lark-push doctor

# List discoverable skills
npx skills add ./ --list

# Manual dry-run (must stay offline: no lark-cli / keychain)
bash skills/lark-push/scripts/lark-push \
  --dry-run \
  --chat-id oc_example \
  --kind code \
  --title "Test" \
  --body "- hello"
```

## Release checklist

1. Update `skills/lark-push/SKILL.md` description triggers if behavior changes
2. Bump `metadata.version` when **behavior** changes (docs-only: no bump)
3. Keep README EN + `README.zh-CN.md` in sync (CLI options, features, install)
4. Run `bash tests/run.sh` (currently 25 offline checks)
5. Tag releases when useful (`vX.Y.Z` matching `metadata.version`)
6. Confirm `npx skills add <owner/repo> --list` shows `lark-push`
