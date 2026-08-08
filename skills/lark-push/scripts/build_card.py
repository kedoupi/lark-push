#!/usr/bin/env python3
"""Build a Feishu / Lark Card 2.0 JSON payload from environment variables.

Expected env vars:
  CARD_KIND   – code | daily | weekly | release | notice
  CARD_TITLE  – card header title
  CARD_LABEL  – human-readable kind label
  CARD_NOW    – timestamp string
  CARD_BODY   – markdown body content (intentional markdown)
  CARD_SOURCE – optional repo/branch context (omit or empty to skip)
  CARD_FOOTER – optional footer caption (defaults to "via lark-push")

Outputs the Card JSON to stdout.
"""

from __future__ import annotations

import json
import os
import sys


REQUIRED = ("CARD_KIND", "CARD_TITLE", "CARD_LABEL", "CARD_NOW", "CARD_BODY")
missing = [v for v in REQUIRED if v not in os.environ]
if missing:
    print(
        f"build_card.py: missing required env vars: {', '.join(missing)}",
        file=sys.stderr,
    )
    sys.exit(2)


def md_escape(text: str) -> str:
    """Escape markdown metacharacters in plain meta fields (not body)."""
    # Order matters: backslash first.
    out = text.replace("\\", "\\\\")
    for ch in ("*", "_", "`", "~", "|", "<", ">"):
        out = out.replace(ch, f"\\{ch}")
    return out


kind = os.environ["CARD_KIND"]
title = os.environ["CARD_TITLE"]
label = os.environ["CARD_LABEL"]
now = os.environ["CARD_NOW"]
source = os.environ.get("CARD_SOURCE", "")
body = os.environ["CARD_BODY"]
footer = os.environ.get("CARD_FOOTER", "via lark-push")

# (color, icon, background). Color is reused for header template,
# text tag, and body accent font color.
themes = {
    "code": ("green", "todo_colorful", "green-50"),
    "daily": ("blue", "calendar_colorful", "blue-50"),
    "weekly": ("violet", "chart_colorful", "violet-50"),
    "release": ("turquoise", "notice_colorful", "turquoise-50"),
    "notice": ("blue", "notice_colorful", "blue-50"),
}
color, icon, bg = themes.get(kind, ("blue", "notice_colorful", "blue-50"))

meta_columns = [
    ("Type", label),
    ("Time", now),
]

if source:
    meta_columns.append(("Source", source))

card = {
    "schema": "2.0",
    "config": {
        "update_multi": True,
        "width_mode": "default",
        "summary": {"content": f"{title} · {label}"},
        "style": {
            "text_size": {
                "caption": {
                    "default": "notation",
                    "pc": "notation",
                    "mobile": "notation",
                },
                "body": {
                    "default": "normal",
                    "pc": "normal",
                    "mobile": "normal",
                },
            }
        },
    },
    "header": {
        "title": {"tag": "plain_text", "content": title},
        "subtitle": {"tag": "plain_text", "content": f"{label} · {now}"},
        "template": color,
        "icon": {"tag": "standard_icon", "token": icon},
        "text_tag_list": [
            {
                "tag": "text_tag",
                "text": {"tag": "plain_text", "content": label},
                "color": color,
            }
        ],
    },
    "body": {
        "direction": "vertical",
        "padding": "12px 12px 20px 12px",
        "vertical_spacing": "12px",
        "elements": [
            {
                "tag": "column_set",
                "flex_mode": "flow",
                "horizontal_spacing": "8px",
                "margin": "0px",
                "columns": [
                    {
                        "tag": "column",
                        "width": "weighted",
                        "weight": 1,
                        "background_style": "grey-50",
                        "padding": "10px 12px 10px 12px",
                        "vertical_spacing": "2px",
                        "elements": [
                            {
                                "tag": "markdown",
                                "content": f"<font color='grey'>{md_escape(name)}</font>",
                                "text_size": "caption",
                            },
                            {
                                "tag": "markdown",
                                "content": f"**{md_escape(value)}**",
                                "text_size": "body",
                            },
                        ],
                    }
                    for name, value in meta_columns
                ],
            },
            {
                "tag": "column_set",
                "flex_mode": "none",
                "margin": "0px",
                "columns": [
                    {
                        "tag": "column",
                        "width": "weighted",
                        "weight": 1,
                        "background_style": bg,
                        "padding": "12px 12px 12px 12px",
                        "vertical_spacing": "4px",
                        "elements": [
                            {
                                "tag": "markdown",
                                "content": f"**<font color='{color}'>Content</font>**",
                            },
                            {
                                "tag": "markdown",
                                "content": body,
                                "text_size": "body",
                            },
                        ],
                    }
                ],
            },
            {
                "tag": "markdown",
                "content": f"<font color='grey'>{md_escape(footer)}</font>",
                "text_size": "caption",
                "text_align": "right",
            },
        ],
    },
}

print(json.dumps(card, ensure_ascii=False, separators=(",", ":")))
