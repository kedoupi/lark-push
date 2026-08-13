# Contributing

Thanks for your interest in improving `lark-push`.

## Development setup

```bash
git clone https://github.com/kedoupi/lark-push-skill.git
cd lark-push-skill
npx skills add ./ --list
bash tests/run.sh
```

## Guidelines

1. Keep `skills/lark-push/SKILL.md` under ~500 lines.
2. Do not hardcode private chat ids, tokens, or team-specific bot names.
3. Prefer durable config at `~/.config/kedoupi/lark-push/config.env`. Legacy `.skill-data/` paths are read/migrate-only.
4. Scripts must resolve their own directory with `pwd -P` so symlink installs work.
5. Keep the default README in **English**; update `README.zh-CN.md` when user-facing docs change.
6. Prefer bash + `lark-cli`; avoid new runtime dependencies beyond `python3` for Card JSON.
7. Bump `metadata.version` in `SKILL.md` when behavior changes (docs-only: no bump).
8. Keep `--dry-run` offline (no `lark-cli` / keychain).
9. Missing deps should print install hints (`doctor`, `require_lark_cli`).

## Validation

```bash
bash tests/run.sh
bash skills/lark-push/scripts/lark-push doctor
bash skills/lark-push/scripts/lark-push \
  --dry-run \
  --chat-id oc_example \
  --kind code \
  --title "Test" \
  --body "- hello"
```

## Pull requests

- Use clear commit messages (Conventional Commits welcome).
- Describe what changed and how you validated it.
- Do not commit local config files or secrets.
