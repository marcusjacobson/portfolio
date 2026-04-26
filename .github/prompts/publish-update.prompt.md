---
description: "Guided publish flow for portfolio updates: branch, summary, screenshot capture, label, and PR creation."
readme-summary: "Guided publish flow: branch, summarize changes, capture screenshots, label the PR, and open it."
argument-hint: "Brief description of the update"
agent: "agent"
---

# Publish a portfolio update

You are helping the user ship a content or styling update to the portfolio site.

## Steps

1. **Check working tree.** Run `git status` and `git diff --stat` to confirm the user's intended changes are staged or unstaged. List any unexpected files.
2. **Branch.** If on `main`, create a feature branch named `update/<kebab-summary>` based on the user's input. Otherwise confirm the current branch is appropriate.
3. **Local validation (best-effort, in this order):**
   - `npm run lint` — HTML/CSS lint.
   - `npm run test:visual` — visual regression. If failures look intentional, ask the user before running `npm run test:visual:update`.
4. **Commit.** Imperative subject, ≤72 chars. Body explains *why* if non-obvious.
5. **Push & PR.** Push the branch and use `gh pr create` with:
   - Title: same as commit subject.
   - Body: Summary and "Tested via" checklist.
   - Labels: `content` (if HTML changed), `style` (if CSS changed), `chore` (otherwise).
6. **Watch checks.** Run `gh pr checks --watch` and report the result.
7. **Hand off.** Tell the user what they should review locally before merging.

## Constraints

- Never push directly to `main`.
- Never run `git push --force` on a shared branch.
- Never auto-merge; the user reviews the preview first.
