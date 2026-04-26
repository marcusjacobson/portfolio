---
description: "Scans .github/agents/ and .github/prompts/ and rewrites the Index tables in both READMEs from current frontmatter. Idempotent. Does not touch hand-authored sections."
readme-summary: "Scans `.github/agents/` and `.github/prompts/` and rewrites the Index tables in both READMEs from the current `readme-summary:` (or `description:`) frontmatter."
argument-hint: "(no arguments)"
agent: "agent"
---

# Sync agent and prompt READMEs

Rebuild the **Index** tables inside `.github/agents/README.md` and `.github/prompts/README.md` from the frontmatter of every `*.agent.md` / `*.prompt.md` file in those folders.

## Source of truth for the Purpose column

The **Purpose** column is rendered from frontmatter using the following precedence:

1. `readme-summary:` — short, repo-aware human prose tuned for these READMEs. **Use this when it exists** so the rendered table is byte-identical to what a human would hand-write.
2. `description:` — fallback only. The agent-router selection text is keyword-rich and verbose; rendering it raw produces wordier rows than the curated style.

Why two fields: `description:` is consumed by the agent/prompt router for relevance matching and is tuned for that audience. `readme-summary:` is consumed by this prompt and is tuned for human readers of the README index. They evolve independently.

## Inputs

None. The prompt operates on whatever is currently checked out.

## Hard rules

- **Issue + branch first.** Per [`request-intake.agent.md`](../agents/request-intake.agent.md), never edit on `main`. If the working tree is on `main`, stop and tell the user to file an issue (or run intake) and create a `chore/<n>-sync-readmes` branch first.
- **Idempotent.** Running this prompt twice in a row must produce zero diff.
- **Bounded edits.** Only the regions delimited by `<!-- BEGIN: agents-index -->` / `<!-- END: agents-index -->` and `<!-- BEGIN: prompts-index -->` / `<!-- END: prompts-index -->` may change. Everything else (How they fit together, Conventions, See also, etc.) is hand-authored and must remain byte-identical.
- **Read-only on missing markers.** If either marker pair is missing from a README, abort with an error pointing the user at the file. Do not invent the markers.
- **Prefer `readme-summary:` over `description:`.** Fall back to `description:` only when `readme-summary:` is missing, and warn so a maintainer can add the field.
- **Skip files without any summary field.** Warn but do not fail.

## Steps

### 1. Pre-flight

```pwsh
$branch = git rev-parse --abbrev-ref HEAD
if ($branch -eq 'main') { throw "Refusing to edit on main. File an issue and create a chore/<n>-sync-readmes branch first." }
foreach ($f in '.github/agents/README.md','.github/prompts/README.md') {
  if (-not (Test-Path $f)) { throw "$f is missing." }
}
```

### 2. Collect agent rows

For each `.github/agents/*.agent.md`:

1. Parse YAML frontmatter; read `readme-summary:` if present, otherwise `description:`. If neither is present, skip the file and warn.
2. If only `description:` was found, emit a warning suggesting the maintainer add a `readme-summary:` field.
3. Derive **Agent** column: `[`@<name>`](<filename>)` where `<name>` is the basename without `.agent.md`.
4. Derive **Purpose** column: use the chosen summary verbatim if it came from `readme-summary:`. If it came from `description:`, paraphrase into 1–2 sentences and strip leading "Use to "/"Use when "/"Specialized " noise.
5. Derive **Mutates repo?** column from explicit signals in the `description:` field (always read this from `description:`, never from `readme-summary:` — the description is keyword-rich and consistently includes mutation-scope signals; the readme-summary is short prose that often omits them):
   - Contains "read-only" or "Read-only by default" → `Read-only` (or `Read-only until approval` if "until approval" / "without explicit user approval" appears).
   - Contains "creates", "merges", "pushes", "opens PR", "drives the gh CLI" → `Yes`.
   - Project-creating agents → `Yes (project + items)`.
   - Otherwise → `Yes`.

Preserve the existing row order from the README when a row already exists; append new rows at the bottom; drop rows whose source file no longer exists.

### 3. Collect prompt rows

For each `.github/prompts/*.prompt.md`:

1. Parse YAML frontmatter; read `readme-summary:` if present, otherwise `description:`. If neither is present, skip the file and warn.
2. If only `description:` was found, emit a warning suggesting the maintainer add a `readme-summary:` field.
3. Derive **Prompt** column: `[`/<name>`](<filename>)` where `<name>` is the basename without `.prompt.md`.
4. Derive **Purpose** column the same way as for agents.
5. **Typical follow-up** column is hand-curated — preserve whatever the existing README row says. For new prompts with no prior row, leave it as `_TBD_` and warn the user to fill it in.

### 4. Render and write

Replace the contents between the markers in each README with a freshly rendered table. Do not change column order, column count, or column headers. Do not modify any byte outside the marker regions.

```pwsh
function Update-IndexBlock {
  param([string]$Path, [string]$BeginMarker, [string]$EndMarker, [string]$NewTable)
  $text  = Get-Content $Path -Raw
  $regex = "(?s)$([regex]::Escape($BeginMarker))\s*\r?\n.*?\r?\n$([regex]::Escape($EndMarker))"
  $repl  = "$BeginMarker`n$NewTable`n$EndMarker"
  $next  = [regex]::Replace($text, $regex, [System.Text.RegularExpressions.Regex]::Escape($repl) -replace '\\','$0' )
  if ($next -eq $text) { return $false }
  Set-Content $Path -Value $next -NoNewline
  return $true
}
```

(Implementation detail — the agent runtime can use any equivalent Markdown-aware mechanism. The contract is what matters: bytes outside the marker block do not change.)

### 5. Report

Print a summary block:

```
sync-agent-prompt-readmes report
--------------------------------
Branch:   <current branch>
Agents README:
  added:    <list>
  removed:  <list>
  updated:  <list>
  unchanged: <count>
Prompts README:
  added:    <list>
  removed:  <list>
  updated:  <list>
  unchanged: <count>
Warnings:
  - <file> has no description: frontmatter
  - <prompt> is new — set its "Typical follow-up" by hand
```

If nothing changed, print `No changes — READMEs already in sync.` and exit.

### 6. Hand off

Stage and commit the change on the current branch with a conventional message:

```pwsh
git add .github/agents/README.md .github/prompts/README.md
git commit -m "Sync agent and prompt README indexes"
```

Do **not** push or open a PR — the user (or `@issue-resolver`) drives the rest of the flow.

## Constraints

- No new dependencies. Pure pwsh + `gh`.
- No touching files outside the two READMEs.
- No reformatting Markdown outside the index blocks (no auto-prettier, no trailing-whitespace cleanup).
- No silent failures. Any parse error or missing marker aborts with a clear message.

## Related

- [`@repo-ops`](../agents/repo-ops.agent.md) — invoke this prompt as part of broader repo housekeeping.
- [Agents README](../agents/README.md) and [Prompts README](README.md) — the two files this prompt maintains.
