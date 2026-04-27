## Source

Scheduled trigger from `.github/workflows/wiki-sync-cron.yml` (run __RUN_URL__).

## Why it matters

The wiki-sync orchestration (`/wiki-sync-run` → `@wiki-sync` → `@request-intake` → `@board-planner`) is a human-in-the-loop chat flow. CI cannot drive it directly, so this scheduled job files a weekly tracking issue to remind a maintainer to run the flow.

The current cursor in `.copilot-tracking/wiki-sync-state.json` is `__LAST_SHA__`. The drift window covered by this run is everything merged onto `main` since that commit, up to `__HEAD_SHA__`.

## Suggested change

Run the orchestration from a Copilot Chat session in this repo:

```text
/wiki-sync-run
```

Optionally pass flags such as `--paths .github/agents/**`, `--max=5`, or `--since=__LAST_SHA__` per the prompt's argument hint.

## Acceptance criteria

- [ ] `/wiki-sync-run` executed and `@wiki-sync` reported either `No deltas` or a routing-table proposal.
- [ ] If deltas were filed, `@board-planner` swept them onto board #16.
- [ ] If the batch fully resolved, the cursor PR (`chore/wiki-sync-cursor-<sha>`) merged so `lastProcessedSha` advances.
- [ ] This tracking issue closed with a one-line outcome comment (filed issues, or `no-op`).
