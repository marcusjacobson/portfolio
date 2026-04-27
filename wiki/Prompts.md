# Prompts

Slash-command prompts (`*.prompt.md`) you invoke in Copilot Chat with `/<prompt-name>`. Each prompt is a single-shot workflow — it runs to completion against the current context and returns. Conversational, multi-turn counterparts live as [agents](Agents).

This page is the wiki-side catalog of every prompt under [`.github/prompts/`](https://github.com/marcusjacobson/portfolio/tree/main/.github/prompts). The repo-side index is [`.github/prompts/README.md`](https://github.com/marcusjacobson/portfolio/blob/main/.github/prompts/README.md), which is auto-rebuilt from prompt frontmatter by [`/sync-agent-prompt-readmes`](https://github.com/marcusjacobson/portfolio/blob/main/.github/prompts/sync-agent-prompt-readmes.prompt.md). If the two ever drift, the prompt frontmatter is the source of truth — the README is rebuilt from it; this wiki page is hand-authored and prose-heavier.

## Catalog

Source of truth for the **Summary** column is each prompt's `readme-summary:` frontmatter (falling back to `description:`). The **Typical inputs** column is condensed from each prompt's `argument-hint:` and *Inputs* / *Steps* sections. The **Common handoff** column lists the agent the prompt most often feeds into next; see [Agents](Agents) for the receiving agent's contract.

| Slash command | Target agent | Summary | Typical inputs | Common handoff |
|---------------|--------------|---------|----------------|-----------------|
| [`/triage-issue`](https://github.com/marcusjacobson/portfolio/blob/main/.github/prompts/triage-issue.prompt.md) | `agent` (default Copilot Chat) | Triage one GitHub issue: classify, label, link to a board, set priority, and post any clarifying questions as a comment. | An issue number (e.g. `137`). | [`@issue-resolver`](Agents) once the issue is fully scoped, or [`@board-planner`](Agents) if the issue belongs in a new board column. |
| [`/groom-backlog`](https://github.com/marcusjacobson/portfolio/blob/main/.github/prompts/groom-backlog.prompt.md) | `agent` | Backlog grooming pass: list open issues, flag duplicates, stale items, and unlabeled work; propose a prioritized batch for the next iteration. | None. Operates on the current open-issues list. | `/triage-issue` on each surfaced item; then [`@boards-worker`](Agents) to drain the prioritized batch. |
| [`/publish-update`](https://github.com/marcusjacobson/portfolio/blob/main/.github/prompts/publish-update.prompt.md) | `agent` | Guided publish flow: branch, summarize changes, capture screenshots, label the PR, and open it. | A brief description of the update (used as the commit subject and branch slug). | [`@publish-manager`](Agents) for full orchestration; [`@security-reviewer`](Agents) on the resulting PR before merge. |
| [`/secure-code-review`](https://github.com/marcusjacobson/portfolio/blob/main/.github/prompts/secure-code-review.prompt.md) | `agent` | Secure review of a PR diff: scans for XSS, secret leakage, supply-chain risk, and unsafe inline scripts; integrates CodeQL and gitleaks results. | A PR number, or `current branch`. | [`@security-reviewer`](Agents) for deeper, contract-bound review and an explicit `APPROVE` / `REQUEST CHANGES` verdict. |
| [`/sync-agent-prompt-readmes`](https://github.com/marcusjacobson/portfolio/blob/main/.github/prompts/sync-agent-prompt-readmes.prompt.md) | `agent` | Scans `.github/agents/` and `.github/prompts/` and rewrites the Index tables in both READMEs from the current `readme-summary:` (or `description:`) frontmatter. | None. Operates on whatever is checked out. | None — emits a diff. Run after adding or editing a prompt or agent file. |
| [`/repo-cleanup`](https://github.com/marcusjacobson/portfolio/blob/main/.github/prompts/repo-cleanup.prompt.md) | `agent` | One-shot entry point to the cleanup workflow. Delegates to [`@repo-cleanup`](Agents); useful when you want a sweep without typing the full agent invocation. | Optional `--scope=<glob>` or `--age=<days>`. | [`@repo-cleanup`](Agents) for the interactive walk. |

## Prompts vs. agents

| | Prompts (`/name`) | Agents (`@name`) |
|---|-------------------|------------------|
| Invocation | `/name` | `@name` |
| Lifetime | One-shot | Multi-turn conversation |
| Best for | Repeatable checklists, scans, single-document operations | Workflows that branch, ask follow-up questions, or hand off |
| State | Stateless | Persists context within a chat session |
| Source | [`.github/prompts/`](https://github.com/marcusjacobson/portfolio/tree/main/.github/prompts) | [`.github/agents/`](https://github.com/marcusjacobson/portfolio/tree/main/.github/agents) |

If you run the same prompt three times in a row with small variations, it probably wants to be an agent. If an agent has one fixed sequence of steps, it probably wants to be a prompt. See [Agents](Agents) for the full agent roster and [Repo-Architecture](Repo-Architecture) for how prompts and agents fit into the chat-prompt-to-merged-PR intake flow.

## How a prompt becomes a merged PR

Prompts never mutate `main`. The typical chain — for any prompt that produces file edits — is:

1. User invokes the prompt (e.g. `/publish-update Add Defender for Cloud capstone`).
2. The prompt runs its checklist against the current working tree and either stages a branch + PR itself or hands the work to an agent.
3. An agent (commonly [`@issue-resolver`](Agents) or [`@publish-manager`](Agents)) takes the branch, runs lint, opens the PR, watches checks, and merges.
4. CI runs the workflows cataloged in [Workflows](Workflows). Required checks must pass before merge; branch protection on `main` enforces this.
5. After merge, [`wiki-sync.yml`](Workflows) and [`pages-deploy.yml`](Workflows) update the wiki and the live site.

Each prompt's frontmatter declares its `agent:` (the runtime that consumes it) and an optional `argument-hint:` (what to pass after the slash command). The two `readme-summary:` and `description:` fields are intentionally separate: `description:` is keyword-rich for the agent router; `readme-summary:` is human-readable prose for index tables like the one above.

## Conventions

- Prompts never push directly to `main`. The intake rule in [`request-intake.agent.md`](https://github.com/marcusjacobson/portfolio/blob/main/.github/agents/request-intake.agent.md) applies.
- Prompts that touch GitHub use the `gh` CLI and echo every command before running it.
- Prompts that produce file edits stage them on a branch.
- Prompts must remain idempotent where the README claims they are (notably `/sync-agent-prompt-readmes`).

## Adding or updating a prompt

1. Create or edit `<name>.prompt.md` under [`.github/prompts/`](https://github.com/marcusjacobson/portfolio/tree/main/.github/prompts) with valid YAML frontmatter. `description:` is required; `readme-summary:` is strongly recommended; `argument-hint:` documents inputs.
2. Run [`/sync-agent-prompt-readmes`](https://github.com/marcusjacobson/portfolio/blob/main/.github/prompts/sync-agent-prompt-readmes.prompt.md) — or ask [`@repo-ops`](Agents) — to regenerate the **Index** table inside `.github/prompts/README.md`.
3. Update this wiki page (`wiki/Prompts.md`) in the same PR if the new prompt changes the catalog or the recommended handoff chain.
4. If the prompt changes a CI-relevant workflow, also update [Workflows](Workflows).

## See also

- [Agents](Agents) — conversational counterparts to these prompts and their handoff graph.
- [Workflows](Workflows) — GitHub Actions catalog: triggers, permissions, secrets, and which checks block PR merges.
- [Repo-Architecture](Repo-Architecture) — folder map and the chat-prompt-to-merged-PR intake flow.
- [Boards](Boards) — GitHub Projects v2 audit log; many prompts feed work onto these boards.
