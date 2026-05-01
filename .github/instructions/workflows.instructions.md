---
description: "Use when creating or modifying GitHub Actions workflows in this repo. Covers least-privilege permissions, action pinning, concurrency, and trigger hygiene."
applyTo: ".github/workflows/**"
---

# Workflow authoring rules

## Required for every workflow

- A `permissions:` block at the workflow OR job level. Default to `contents: read`.
- A meaningful `name:` and `on:` trigger; avoid `on: push` without a branch filter.
- `concurrency:` for any workflow that deploys, comments on PRs, or pushes to a branch.
- Pin actions: use `@vN` major tags at minimum; pin third-party actions to a full SHA.

## Permissions cheat sheet

| Capability | Permission |
|------------|------------|
| Read code | `contents: read` |
| Push commits / tags | `contents: write` |
| Comment on PRs / issues | `pull-requests: write` / `issues: write` |
| Upload SARIF / CodeQL | `security-events: write` |
| Pages deploy via Actions | `pages: write`, `id-token: write` |

## Triggers

- `pull_request` should specify `branches: [main]` and, where useful, `paths:` to skip irrelevant runs.
- Scheduled jobs (`schedule.cron`) should also expose `workflow_dispatch` for manual runs.
- Avoid `pull_request_target` unless you understand the security implications (untrusted code with write token).

## Secrets & tokens

- Use `${{ secrets.GITHUB_TOKEN }}` whenever possible — never store a PAT in the repo.
- Mask any echoed values with `::add-mask::` if they could leak into logs.

## Anti-patterns

- `permissions: write-all` — never. Grant per job.
- Unpinned `uses: actions/checkout@main` — pin to `@v4` minimum.
- Overlapping deploy workflows without `concurrency:` — causes race conditions on Pages.
- Using `pull_request_target` to comment on PRs when `pull_request` + `permissions: pull-requests: write` works.

## Tested gotchas (verified in this repo)

### Heredoc inside `run: |` breaks the YAML block scalar

A `cat <<EOF ... EOF` heredoc whose body has any column-0 line will terminate the YAML block scalar early. The workflow registers as active, but every push fails with `Invalid workflow file ... line N` and `gh workflow run` returns a misleading HTTP 422 `Workflow does not have workflow_dispatch trigger`.

Don't:

```yaml
- name: File issue
  run: |
    BODY=$(cat <<EOF
    ## Source
    Some text at column 0.   # ← terminates the block scalar
    EOF
    )
```

Do — extract the body to a template under `.github/workflows/templates/` and substitute placeholders:

```yaml
- name: File issue
  run: |
    read_body () { sed "s|__PATH__|$1|g" .github/workflows/templates/repo-hygiene-issue-body.md; }
    BODY=$(read_body "$path")
```

See `maturity-scan.yml` (`read_body` helper, ~line 58) for the working pattern.

### Path-filtered jobs cannot be required PR contexts

A workflow with a `paths:` filter that sometimes does not run (e.g., the `build` job in `pages-deploy.yml` on a docs-only PR) **cannot** be a required status check, or PRs deadlock waiting for a check that never registers. Either drop the `paths:` filter (run always, fast-exit when irrelevant) or remove the context from `apply-branch-protection.ps1`'s required list.

### Matrix job context names include the matrix value

`actions/codeql-action`'s `analyze` job renders as `analyze (javascript-typescript)` — required-context strings in branch protection must match the rendered name including the matrix params in parens, not the bare job name.

### `gh api` boolean serialization

`-f enabled=true` sends the **string** `"true"` and a JSON-typed boolean field returns 422. Use `ConvertTo-Json` and pipe to `--input -`:

```pwsh
@{ enabled = $true } | ConvertTo-Json | gh api ... --input -
```

## Best-practice sources

When auditing a workflow against external recommendations (during PR review or `@maturity-scout` runs), ground in the canonical URLs catalogued in [grounding-sources.instructions.md](grounding-sources.instructions.md) — Actions security hardening, `permissions:` reference, third-party action pinning, and `pull_request_target` security model.
