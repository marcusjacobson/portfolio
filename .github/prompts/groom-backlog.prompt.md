---
description: "Backlog grooming pass: list open issues, identify duplicates, stale items, and unlabeled work; propose a prioritized batch for the next iteration."
agent: "agent"
---

# Groom the backlog

## Steps

1. List open issues: `gh issue list --state open --limit 100 --json number,title,labels,updatedAt,assignees`.
2. Identify:
   - **Stale**: no update in 60+ days.
   - **Duplicates**: similar titles or bodies (call out, don't auto-close).
   - **Unlabeled**: missing type/priority/area.
   - **Unassigned p0/p1**: needs owner.
3. Output a markdown report in this format:
   ```
   ## Backlog groom — <date>

   ### Top priorities (next iteration)
   1. #<n> <title>  — why
   2. ...

   ### Needs labeling
   - #<n> <title>

   ### Likely duplicates
   - #<a> ⇄ #<b>

   ### Stale (suggest closing or pinging)
   - #<n> <title>  (last update <date>)
   ```
4. Do **not** auto-close, auto-label, or auto-comment. Output only.

## Constraints

- Read-only. The user reviews the report and decides what to action.
