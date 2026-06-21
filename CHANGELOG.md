# Changelog

All notable user-visible changes to this portfolio site are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project loosely tracks dated entries (no strict semver).

## [Unreleased]

### Added

- Active **GitHub projects** buttons on the Security Compass *Purview as Code*,
  *Microsoft Purview*, and *IaC Foundations* nodes, linking the generic
  Purview-as-Code template repository.
- Per-page "Last updated" footer line, populated at deploy time from the last
  Git commit that touched each page.
- Public `changelog.html` page, generated from this file at deploy time and
  linked from the site footer.

### Changed

- Repointed the Projects page *Purview-as-Code* card to the tenant-neutral
  generic template repository (`Purview-as-Code-Generic`) and refreshed its
  outcome and next-steps copy to reflect the two-plane design (Bicep control
  plane + YAML/PowerShell data plane).
- Moved the Security Compass page's "Navigate" dropdown out of the centered hint row and into the standard sticky top bar, matching every other page.
- Replaced the top-of-page navigation button row with a single accessible dropdown menu ("Navigate") across all pages, including a new top bar on the landing and changelog pages. The menu now lists every page (Home, Security Compass, Roles & Scenarios, Projects, Certifications, Skills, Changelog) and marks the current page.
- Completed cross-page navigation so every main page links to all of the
  others. Added the missing **Home** and **Skills** links to the top nav and
  footer of the Roles, Projects, and Certifications pages, and the missing
  **Compass** and **Roles** links (plus a footer page-nav row) on the Skills
  page.

## [2026-04-27]

### Added

- Weekly `wiki-sync` cron tracker workflow that opens an issue when the local
  `wiki/` source drifts from the published GitHub Wiki.
- `@wiki-sync` detector agent and `/wiki-sync-run` prompt orchestrating intake
  and sweep across drift batches.
- Extended `@board-planner` sweep mode for wiki-sync batches.
- `agent:*` labels added to the `labels.yml` manifest.

### Changed

- Wiki `Agents.md` page split into local-vs-hosted sections with a decision
  guide for when to author each shape.
- `README.md` Agents section now links to Projects, the wiki, and the
  `AGENTS.md` tracker as authoritative sources.

### Fixed

- `request-intake` agent now correctly recognizes `@wiki-sync` handoffs and
  routes ambiguous wiki-content asks to the dedicated detector.

## [2026-04-26]

### Added

- `@project-intake` agent that creates roadmap items directly as Project v2
  draft issues on the Security Portfolio Roadmap board.
- Deployment-Rules wiki page describing the static-site publishing model and
  the no-build-step contract.

### Changed

- Repo-Hygiene Maturity Scout (`maturity-scan.yml`) extracted heredoc issue
  body into a reusable template under `.github/workflows/templates/`.

## [2026-04-25]

### Added

- Visual regression Playwright suite covering all six root HTML pages, with
  baselines committed under `tests/visual/__snapshots__/`.
- `htmlhint` and `stylelint` CI on every pull request via `html-css-lint.yml`.

### Fixed

- `pages-deploy.yml` permissions tightened to least-privilege per job
  (`contents: read`, `pages: write`, `id-token: write` only on the deploy job).
