# `.copilot-tracking/`

Durable, audit-friendly state files used by the repo's Copilot agents. Files here **are tracked in git** so every state transition is visible in PR diffs and `git log`. This folder is intentionally **not** in `.gitignore`.

> If you ever need to suppress audit noise for a high-frequency cursor, the documented fallback is a repo variable (e.g. `gh variable set WIKI_SYNC_LAST_SHA`). Record that decision in the PR that introduces the change.

## Files

| File | Owner | Purpose |
|------|-------|---------|
| [`wiki-sync-state.json`](wiki-sync-state.json) | [`@wiki-sync`](../../wiki/Agents.md) (design tracked in [#143](https://github.com/marcusjacobson/portfolio/issues/143)) | Last-processed commit SHA + last batch summary. Schema: [`wiki-sync-state.schema.json`](wiki-sync-state.schema.json). |

## `wiki-sync-state.json` schema

The contract is enforced by [`wiki-sync-state.schema.json`](wiki-sync-state.schema.json). At a glance:

```jsonc
{
  "lastProcessedSha": "<40-char SHA on main>",
  "lastRunAt": "<ISO-8601 UTC, e.g. 2026-04-27T12:25:39Z>",
  "lastBatchSummary": {
    "filed":     [/* issue numbers or short ids the agent handed off */],
    "deferred":  [/* items flagged but not filed this run */],
    "cancelled": [/* items the operator dismissed this run */]
  }
}
```

Field rules:

- `lastProcessedSha` — full 40-character SHA. The next `@wiki-sync` run computes the delta `lastProcessedSha..HEAD` against `wiki/**`.
- `lastRunAt` — ISO-8601 UTC timestamp with the `Z` suffix.
- `lastBatchSummary.{filed,deferred,cancelled}` — all three keys are required; empty arrays are valid (the seed entry uses empty arrays).
- The optional `_seed` object documents the initial commit and is removed (or overwritten) on the first real `@wiki-sync` run.

## Update protocol

`@wiki-sync` overwrites this file at the end of every batch as part of the same PR/commit that files the delta issues, so the cursor advance and the audit trail land together. Operators editing this file by hand should:

1. Validate against the schema before committing.
2. Use an imperative commit subject like `chore(wiki-sync): advance cursor to <short-sha>`.
3. Never push directly to `main` — open a PR per repo conventions.
