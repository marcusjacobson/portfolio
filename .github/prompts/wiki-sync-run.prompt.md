---
description: "End-to-end wiki-sync run: invoke @wiki-sync to detect repo↔wiki drift since the last cursor, hand each delta to @request-intake, then sweep the filed issues onto board #16 via @board-planner, and advance the cursor only on full-batch resolution."
readme-summary: "End-to-end wiki-sync run: detect repo↔wiki drift via @wiki-sync, file each delta through @request-intake, sweep onto board #16 via @board-planner, and advance the state cursor only when the whole batch resolves."
argument-hint: "Optional flags forwarded to @wiki-sync (e.g. --paths .github/agents/** --max=5 --since=<sha>)"
agent: "agent"
---

# Run the wiki-sync flow

You are orchestrating the full wiki-sync pipeline end-to-end. You do not detect drift yourself, you do not draft issues yourself, and you do not place items on boards yourself — every mutation flows through the named agent at the named step. Your job is to chain them in order, surface each agent's proposal block to the user verbatim, and stop the moment the user cancels.

## Steps

1. **Read the current cursor.** Echo and run:

   ```pwsh
   Get-Content .copilot-tracking/wiki-sync-state.json -Raw | ConvertFrom-Json
   git rev-parse origin/main
   ```

   Capture `lastProcessedSha` and the current `origin/main` HEAD. If `--since=<sha>` was passed by the user, note that it overrides the cursor for this run only.

2. **Invoke `@wiki-sync` for detection.** Forward any user-supplied flags (`--paths`, `--max`, `--since`). Wait for `@wiki-sync` to print its **proposal block** (the `Wiki-sync run — <date> — routing table v<n>` section with `Proposed deltas`, `Suppressed (dedupe)`, and `Out-of-routing`).

   - If `@wiki-sync` reports `No deltas since <sha>.`, output the same line, do **not** advance the cursor (no-op runs leave the SHA accurate already), and exit.
   - Otherwise, present the proposal block to the user verbatim and wait for one of: `file all`, `file <N>[,<M>...]`, `edit <N>: <changes>`, or `cancel`.

3. **On `cancel` at detection time.** Acknowledge, do **not** call `@request-intake`, do **not** call `@board-planner`, do **not** write the state file. Print the final summary line with the cursor unchanged (see step 7) and exit.

4. **Loop `@request-intake` per approved delta.** For each approved delta in the order presented:

   1. Hand the JSON payload (exactly as `@wiki-sync` rendered it) to `@request-intake`.
   2. Let `@request-intake` run its standard live-label validation, duplicate sweep, proposal, and approval gate. The user re-confirms each issue at intake time.
   3. Echo every `gh` command `@request-intake` runs (it does this itself; do not suppress).
   4. Capture the outcome per delta:
      - `filed` → record `{deltaIndex, issueNumber, issueUrl, targetWikiPage}`.
      - `deferred` → `@request-intake` reported a duplicate or out-of-scope; record `{deltaIndex, reason, dupOfIssue?}`.
      - `cancelled` → user dismissed at intake; record `{deltaIndex}`.
   5. If the user types `cancel` at any intake prompt, stop the loop immediately. Do not file the remaining approved deltas, do not call `@board-planner`, do not advance the cursor. Skip to step 7.

5. **Hand the filed issues to `@board-planner`.** Only run this step if at least one delta was filed in step 4 and the user did not cancel.

   - Pass the array of filed issue numbers to `@board-planner` in **Wiki-sync batch sweep** mode against board #16 (it applies the cross-tag rule for board #15 internally — do not second-guess it).
   - Echo every `gh project` and `gh issue edit` command `@board-planner` runs.
   - `@board-planner` will print its own diff block before mutating and require its own approval. The user can `cancel` there.
   - Capture the board sweep diff text (issues added, fields set, items left unattached).
   - If the user cancels at the board-planner stage, treat the run as a partial batch. Filed issues remain filed (do not roll them back), but the cursor does **not** advance — skip to step 7.

6. **Advance the cursor (only on full-batch resolution).** A batch is fully resolved when every approved delta from step 2 reached a terminal outcome (`filed`, `deferred`, or `cancelled`) AND `@board-planner` completed its sweep without a user cancel.

   - On a feature branch named `chore/wiki-sync-cursor-<short-sha>` (cut from latest `origin/main`), write the new state file:

     ```pwsh
     git checkout -b chore/wiki-sync-cursor-<short-sha> origin/main
     $state = @{
       '$schema'        = './wiki-sync-state.schema.json'
       lastProcessedSha = '<originHead full 40-char SHA>'
       lastRunAt        = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ')
       lastBatchSummary = @{
         filed     = @(<filed issue numbers>)
         deferred  = @(<deferred identifiers>)
         cancelled = @(<cancelled identifiers>)
       }
     } | ConvertTo-Json -Depth 4
     $state | Set-Content .copilot-tracking/wiki-sync-state.json -Encoding UTF8
     git add .copilot-tracking/wiki-sync-state.json
     git commit -m "chore: advance wiki-sync cursor to <short-sha>"
     git push -u origin chore/wiki-sync-cursor-<short-sha>
     gh pr create --fill --label chore --label agent:wiki-sync
     ```

   - Never push the state-file commit directly to `main`. Always open a PR.
   - On a partial batch, **roll back**: do not write the state file, do not open the cursor PR. The next run will recompute against the unchanged `lastProcessedSha`, and `@wiki-sync`'s dedupe step will suppress the issues that were already filed.

7. **Print the final summary line.** Exactly one line, in this shape:

   ```text
   <N> filed, <M> deferred, <K> cancelled, board sweep diff: <one-line summary or "skipped">, new SHA: <newSha[:8] or "unchanged">
   ```

   - `<N>` = count of `filed` deltas.
   - `<M>` = count of `deferred` deltas.
   - `<K>` = count of `cancelled` deltas (includes any approved-but-skipped deltas if the user cancelled mid-batch).
   - `board sweep diff:` — one-line summary from `@board-planner` (e.g. `+3 to board #16, +1 to board #15`), or the literal `skipped` if step 5 did not run (no deltas filed, or user cancelled before board sweep).
   - `new SHA:` — the 8-char prefix of the advanced SHA, or the literal `unchanged` on a partial batch / no-op / cancel.

   Optionally precede the summary line with the per-issue list `@wiki-sync` already produces (`#<n> — <title> — <url> — <board>`) so the user can copy-paste, but the final line above is mandatory and must be the last line of output.

## Constraints

- **Never call `gh issue create`, `gh project item-add`, or `gh project item-edit` directly from this prompt.** All filing goes through `@request-intake`; all board placement goes through `@board-planner`.
- **Never edit `wiki/*.md` from this prompt.** Wiki edits land on their own branches via the issues filed in step 4, picked up by `@issue-resolver` later.
- **Echo every `gh` and `git` command before running it.** No silent mutations.
- **Cancel is sticky.** Once the user types `cancel` at any stage, do not advance the cursor and do not retry.
- **Cursor advances atomically.** Either every approved delta is terminal and the cursor moves forward via the PR in step 6, or the cursor stays exactly where it was. Never write a partial cursor.
- **One run per invocation.** Do not chain a second `@wiki-sync` detection pass after step 5 completes.
- **No `--admin`, no force-push, no `--no-verify`.** The cursor PR follows the same checks as every other PR in the repo.

## See also

- [`@wiki-sync`](../agents/wiki-sync.agent.md) — detector that produces the proposal block consumed in step 2.
- [`@request-intake`](../agents/request-intake.agent.md) — files each delta as a tracked issue in step 4.
- [`@board-planner`](../agents/board-planner.agent.md) — sweeps the filed issues onto board #16 in step 5.
- [`.copilot-tracking/wiki-sync-state.json`](../../.copilot-tracking/wiki-sync-state.json) — durable cursor advanced in step 6.
