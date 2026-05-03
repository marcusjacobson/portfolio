# GitHub Pages Publishing Guide — MS Security Compass

## Repository

**`marcusjacobson/portfolio`** — [github.com/marcusjacobson/portfolio](https://github.com/marcusjacobson/portfolio)

Live URL:
```
https://marcusjacobson.github.io/portfolio/
```

## Status — ✅ Complete

| Step | Status |
|---|---|
| Repo created with all four HTML files | ✅ Done |
| GitHub Pages enabled (`main` / root) | ✅ Done |
| HTTPS enforced | ✅ Done |
| Placeholder pages confirmed live | ✅ Done |

---

## Updating files from VS Code

When ready to push the real files from this project:

```bash
cd /path/to/portfolio
cp /path/to/ms_security_compass_vN.html index.html
cp /path/to/ms_security_roles_v2.html ms_security_roles.html
cp /path/to/ms_security_projects_v1.html ms_security_projects.html
cp /path/to/certification_strategy_v1.html certification_strategy.html
git add .
git commit -m "Publish MS Security Compass v19 — initial content"
git push
```

Pages redeploys automatically on every push to `main`. No workflow file or Actions config needed.

---

## Ongoing iteration workflow

Each time you update the compass in Claude and download the new version:

```bash
cp /path/to/new-compass.html index.html
git add index.html
git commit -m "Compass v20 — [describe change]"
git push
```

---

## Optional enhancements (for later)

**`sendPrompt()` fallback** — the "Real-world scenario ↗" buttons are no-ops outside Claude.ai. To make them open a pre-filled Claude conversation instead, add this just before the closing `</script>` tag in `index.html`:

```js
if (typeof sendPrompt === 'undefined') {
  window.sendPrompt = function(text) {
    window.open('https://claude.ai/new?q=' + encodeURIComponent(text), '_blank');
  };
}
```

**Cross-page navigation** — paste this just after the `<body>` tag in each HTML file to link the four pages together:

```html
<nav style="font-family:system-ui,sans-serif;font-size:13px;padding:8px 16px;
  background:#111;border-bottom:1px solid #333;display:flex;gap:20px;flex-wrap:wrap">
  <a href="index.html" style="color:#aaa;text-decoration:none">🧭 Compass</a>
  <a href="ms_security_roles.html" style="color:#aaa;text-decoration:none">👤 Roles</a>
  <a href="ms_security_projects.html" style="color:#aaa;text-decoration:none">📁 Projects</a>
  <a href="certification_strategy.html" style="color:#aaa;text-decoration:none">🎓 Certifications</a>
</nav>
```

**Custom domain** — add a `CNAME` file to the repo root with your domain, then configure DNS to point to `marcusjacobson.github.io`.

---

## Staging preview (PR-side)

There is no externally-hosted staging URL. Instead, every PR runs the same render pipeline as production via the reusable [`pages-build.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/pages-build.yml) workflow and uploads the rendered tree as a downloadable `site-preview` artifact (14-day retention).

Before merging a content PR, fetch and serve the artifact locally:

```powershell
./scripts/preview-pr.ps1 -Pr <number>
```

The script downloads the latest successful `pages-build` artifact for the PR's head SHA, unpacks it under `staging-inbox/pr-<N>/`, and starts `npx http-server` on `http://localhost:8080/`. Click through the four portfolio pages, the changelog, and any newly added pages before approving the merge.

The [`@publish-manager`](Agents) agent treats this preview step as a hard gate: it will not advise merging a content PR until the maintainer signs off on the local preview.

The deploy pipeline ([`pages-deploy.yml`](https://github.com/marcusjacobson/portfolio/blob/main/.github/workflows/pages-deploy.yml)) calls the same reusable build on push to `main` and feeds the result into [`actions/deploy-pages`](https://github.com/actions/deploy-pages), so PR previews and the live site are bit-identical.
