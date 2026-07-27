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
    SKILL.md           # required skill definition
    scripts/           # executable helpers
    templates/         # optional body templates
```

## Editing rules

- Keep `SKILL.md` under ~500 lines; put long references in separate files.
- Do not hardcode private chat ids, tokens, or team-specific bot names.
- Require `LARK_PUSH_CHAT_ID` or `--chat-id` for real sends.
- Scripts must resolve their own directory and work after install to any agent path.
- Prefer bash + `lark-cli`; avoid extra runtime dependencies beyond `python3` for JSON card build.

## Config design

- Do **not** store secrets only inside the skill package: `npx skills update` wipes that directory.
- Durable config lives at `<skills-parent>/.skill-data/lark-push/config.env`.
- After install users run `bash scripts/lark-push init --chat-id oc_xxx`.
- `npx skills add` has no post-install hook; init is intentional.

## Local validation

```bash
# List discoverable skills
npx skills add ./ --list

# Init durable config next to a simulated install tree, then dry-run
bash skills/lark-push/scripts/lark-push init --chat-id oc_example --force
bash skills/lark-push/scripts/lark-push which-config
bash skills/lark-push/scripts/lark-push \
  --dry-run \
  --kind code \
  --title "Test" \
  --body "hello"
```

## Release checklist

1. Update `skills/lark-push/SKILL.md` description triggers if behavior changes
2. Keep README install command accurate
3. Tag releases when useful (`v0.x.y`)
4. Confirm `npx skills add <owner/repo> --list` shows `lark-push`
