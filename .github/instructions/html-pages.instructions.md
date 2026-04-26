---
description: "Use when authoring or editing the static HTML portfolio pages. Covers semantic HTML, accessibility baseline, inline-asset rules, and SEO basics."
applyTo: "*.html"
---

# HTML page authoring

## Required structure

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>{Page title} — Marcus Jacobson Portfolio</title>
  <meta name="description" content="{1–2 sentence summary}" />
</head>
<body>
  <!-- content -->
</body>
</html>
```

## Accessibility baseline

- Every `<img>` needs a meaningful `alt`. Decorative images get `alt=""`.
- Use one `<h1>` per page; nest headings without skipping levels.
- Interactive elements must be reachable by keyboard and have visible focus styles.
- Color contrast ≥ 4.5:1 for text. Avoid pure-color signaling without a label or icon.
- Use semantic elements (`<nav>`, `<main>`, `<section>`, `<article>`, `<footer>`) over `<div>` soup.

## Inline assets

- Inline CSS and JS are fine for self-contained pages.
- If you extract a file, place under `assets/` and reference with a **relative** path (`./assets/foo.css`), never absolute (`/assets/foo.css`) — the site is also opened directly from disk during dev.
- External scripts must use HTTPS and SRI (`integrity=`) when loaded from a CDN.

## Performance

- Defer non-critical JS with `defer` or `async`.
- Lazy-load below-the-fold images: `loading="lazy"`.
- Preconnect to font/script origins; don't load fonts you don't use.

## Linting

`htmlhint` runs on every PR with the rules in `.htmlhintrc`. Fix locally with `npm run lint:html`.

## Visual regression

Any visual change should be verified with `npm run test:visual`. If the change is intentional, regenerate baselines with `npm run test:visual:update` and commit the snapshot diffs.
