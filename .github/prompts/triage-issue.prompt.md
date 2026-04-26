---
description: "Triage a single GitHub issue: classify, label, link to project, set priority, and ask any clarifying questions in a comment."
readme-summary: "Triage one GitHub issue: classify, label, link to a project, set priority, and post any clarifying questions as a comment."
argument-hint: "Issue number"
agent: "agent"
---

# Triage an issue

## Steps

1. Read the issue: `gh issue view <n> --json title,body,labels,author,createdAt`.
2. Classify into one of: `bug`, `content-update`, `new-page`, `link-rot`, `chore`, `question`.
3. Apply labels (create if missing):
   - Type label (one of the above).
   - `priority:p0|p1|p2|p3` based on impact.
   - `area:html|css|workflow|wiki|docs` based on what it touches.
4. If the issue has an obvious owner (you), self-assign.
5. Add to the "Portfolio" project board if one exists (`gh project item-add`).
6. If clarification is needed, post **one** comment with crisp, numbered questions. Do not pepper the reporter.
7. Output a one-line summary: `#<n>: <title> → <type>/<priority>/<area>`.

## Constraints

- DO NOT close the issue. Only triage.
- DO NOT request changes that the user hasn't asked for.
