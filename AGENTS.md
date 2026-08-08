# AGENTS.md

Guidance for AI coding agents working in this repository.

## Purpose

This repo publishes one installable agent skill: `lark-push`.

Users install it with:

```bash
npx skills add kedoupi/lark-push
```

## Layout

```text
skills/
  lark-push/           # skill package (discovered by skills CLI)
    SKILL.md           # required skill definition (version source of truth)
    scripts/
      lark-push        # main CLI
      build_card.py    # Card 2.0 JSON builder
      git-post-commit-lark-push
    templates/         # optional body templates
tests/
  run.sh               # offline self-test (no keychain / network)
```

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
