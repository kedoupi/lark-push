# Contributing

Thanks for your interest in improving `lark-push`.

## Development setup

```bash
git clone https://github.com/kedoupi/lark-push.git
cd lark-push
npx skills add ./ --list
```

## Guidelines

1. Keep `skills/lark-push/SKILL.md` under ~500 lines.
2. Do not hardcode private chat ids, tokens, or team-specific bot names.
3. Prefer durable config under `<skills-parent>/.skill-data/lark-push/`.
4. Scripts must resolve their own directory with `pwd -P` so symlink installs work.
5. Keep the default README in **English**; update `README.zh-CN.md` when user-facing docs change.
6. Prefer bash + `lark-cli`; avoid new runtime dependencies beyond `python3` for Card JSON.

## Validation

```bash
bash skills/lark-push/scripts/lark-push init --chat-id oc_example --force
bash skills/lark-push/scripts/lark-push which-config
bash skills/lark-push/scripts/lark-push \
  --dry-run \
  --kind code \
  --title "Test" \
  --body "hello"
```

## Pull requests

- Use clear commit messages (Conventional Commits welcome).
- Describe what changed and how you validated it.
- Do not commit local config files or secrets.
