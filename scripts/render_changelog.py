#!/usr/bin/env python3
"""Render CHANGELOG.md into changelog.html.

Reads the body HTML produced by pandoc (path passed as argv[1]) and substitutes
it into changelog.html between `<!-- CHANGELOG_BODY -->` markers.

Run from the repo root. Used by .github/workflows/pages-deploy.yml.
"""
from __future__ import annotations

import pathlib
import re
import sys


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: render_changelog.py <body-html-path>", file=sys.stderr)
        return 2
    body_path = pathlib.Path(sys.argv[1])
    page_path = pathlib.Path("changelog.html")
    if not body_path.is_file():
        print(f"body file not found: {body_path}", file=sys.stderr)
        return 1
    if not page_path.is_file():
        print(f"changelog.html not found at {page_path}", file=sys.stderr)
        return 1
    body = body_path.read_text(encoding="utf-8")
    page = page_path.read_text(encoding="utf-8")
    new = re.sub(
        r"<!-- CHANGELOG_BODY -->.*?<!-- /CHANGELOG_BODY -->",
        "<!-- CHANGELOG_BODY -->\n" + body + "\n<!-- /CHANGELOG_BODY -->",
        page,
        flags=re.DOTALL,
    )
    page_path.write_text(new, encoding="utf-8")
    return 0


if __name__ == "__main__":
    sys.exit(main())
