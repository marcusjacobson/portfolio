---
description: "Run a repo-cleanup sweep: scan for stale work artefacts, present a numbered proposal list, then walk it one item at a time with remove | keep | skip."
readme-summary: "One-shot entry point to the cleanup workflow. Delegates to `@repo-cleanup`; useful when you want a sweep without typing the full agent invocation."
argument-hint: "Optional scope path or `--age=<days>` flag"
agent: "agent"
---

# Repo cleanup sweep

You are running the cleanup workflow defined in [`.github/agents/repo-cleanup.agent.md`](../agents/repo-cleanup.agent.md). Follow that agent's protocol verbatim — do not improvise.

## Steps

1. **Engage `@repo-cleanup`.** Apply any `--scope=`, `--age=`, or `--no-branches` argument the user provided. Default `--age=14` and include local merged branches.
2. **Open issue + branch first** (step 0 of the agent file). File a `chore,area:workflow,priority:p3` tracking issue, then create `chore/<N>-repo-cleanup-sweep` from `main`. Never run discovery or any mutation while still on `main`.
3. **Run the prepare phase** (the parallel discovery commands listed in the agent file).
4. **Print the one-line summary and the FIRST candidate only.** Use the per-item block shape from step 3 of the agent file (`[1/<N>] <class> <path>` with `reason:`, `action on remove:`, `remediation on keep:`). Do not print item 2 in the same turn.
5. **Walk one item at a time.** Wait for `remove`, `keep`, `skip`, `show all`, or `quit` between every item. Bare verbs apply to the currently-prompted item. Echo destructive commands before running them. Always present exactly one candidate per assistant turn.
6. **Apply remediations on `keep`** using the per-class table in the agent file (`.gitignore`, `.cleanupignore`, in-file `# cleanup:keep` marker, or rename).
7. **Print the final report** when the user types `quit` or every item has been answered.
8. **Commit, push, and open a PR** linked to the tracking issue (step 7 of the agent file). Never auto-merge; hand control back to the user once checks are green.

## Constraints

- Read-only by default. No deletes, no branch removals, no file edits without per-item user approval in the same turn.
- Never run discovery or mutations on `main`. Always operate from `chore/<N>-repo-cleanup-sweep`.
- Never push branch deletes to `origin`; local-only `git branch -d`.
- Commits and the closing PR happen at the end (step 8) under the tracking issue. Never auto-merge.
- If a candidate is tracked in git and not on a known stale-output path, escalate before proposing removal.
