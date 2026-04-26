---
description: "Use when authoring or editing wiki content under wiki/. Covers tone, link conventions, and the one-way sync model to the GitHub wiki."
applyTo: "wiki/**"
---

# Wiki content rules

The `wiki/` folder is the **source of truth** for the GitHub wiki. The `wiki-sync.yml` workflow pushes this folder to `portfolio.wiki.git` on every push to `main`. Edits made directly on github.com to the wiki will be **overwritten** on the next sync.

## File layout

- `wiki/Home.md` is the wiki landing page (required).
- One topic per file. Filename becomes the wiki page name (`Foo-Bar.md` → "Foo Bar").
- Use sentence case for wiki page filenames; hyphens for spaces.

## Tone & style

- Match the [writing-style](../../CONTRIBUTING.md) of the rest of the repo: direct, second-person, no marketing fluff.
- Lead with the answer; provide context after.
- Prefer tables for reference content; prose for procedures.

## Links

- Internal wiki links: `[Page Name](Page-Name)` — no `.md` extension, hyphens for spaces.
- Links to repo files: full HTTPS GitHub URL, since wiki and repo are separate Git contexts.
- External links: full HTTPS URL.

## Things not to do

- Don't edit on github.com — your changes will be lost. Edit `wiki/*.md` and PR.
- Don't commit large binaries to `wiki/`. Reference repo `assets/` via HTTPS.
- Don't link to draft / unpublished pages.
