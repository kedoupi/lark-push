# Documentation

Human-facing docs for **lark-push-skill**. Not part of the installable package.

## Layout

```text
docs/
├── README.md
└── screenshots/          # curated README gallery
    ├── daily-feature.png
    ├── daily-project.png
    └── notice-install.png
```

## Separation (incubator contract)

| Tree | Role |
| --- | --- |
| `skills/lark-push/` | Installable package |
| `docs/` | Guides + curated screenshots |
| `tests/` | Offline `run.sh` only today |
| `artifacts/` | Reserved for future live dumps (none yet) |

Do not put raw live dumps under `docs/`. See parent incubator `schema/skill-repo.md`.
