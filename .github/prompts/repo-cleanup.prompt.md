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
2. **Run the prepare phase** (the parallel discovery commands listed in the agent file).
3. **Produce the numbered proposal list** in the exact block format the agent specifies. No prose framing.
4. **Walk the list one item at a time.** Wait for `<n> remove`, `<n> keep`, `<n> skip`, or `quit` between every item. Echo destructive commands before running them.
5. **Apply remediations on `keep`** using the per-class table in the agent file (`.gitignore`, `.cleanupignore`, in-file `# cleanup:keep` marker, or rename).
6. **Print the final report** when the user types `quit` or every item has been answered.

## Constraints

- Read-only by default. No deletes, no branch removals, no file edits without per-item user approval in the same turn.
- Never push branch deletes to `origin`; local-only `git branch -d`.
- Never commit on the user's behalf. The user reviews the remediation diff and commits manually.
- If a candidate is tracked in git and not on a known stale-output path, escalate before proposing removal.
