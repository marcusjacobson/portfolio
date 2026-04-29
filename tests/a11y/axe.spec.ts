import { test } from '@playwright/test';
import AxeBuilder from '@axe-core/playwright';
import { mkdirSync, readdirSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

// Issue #127 — WCAG axe-core scan run via Playwright.
//
// Loads each top-level portfolio page over the Playwright `baseURL`
// (the maturity-scan workflow boots a local http-server on :8080
// before invoking this spec) and runs axe-core against the rendered
// DOM. Unlike `@axe-core/cli` (Option B, issue #126), this exercises
// the full computed-style tree, which is the prerequisite for
// `color-contrast` findings.
//
// Each page's axe results are written as JSON to
// `<repoRoot>/.axe-pw-reports/<page-slug>.json`. The workflow's
// `scan_wcag_axe_pw` step aggregates that directory using the same
// rule-id grouping logic as Option B.

const repoRoot = resolve(__dirname, '..', '..');
const reportDir = resolve(repoRoot, '.axe-pw-reports');

// Same scope as the workflow: every top-level *.html in the repo root.
function discoverPages(): string[] {
  return readdirSync(repoRoot)
    .filter((name) => name.toLowerCase().endsWith('.html'))
    .sort();
}

const PAGES = discoverPages();

mkdirSync(reportDir, { recursive: true });

// Tag set mirrors Option B (`@axe-core/cli --tags ...`) so the rule
// surface is comparable when both scans run.
const AXE_TAGS = ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'wcag22aa'];

for (const page of PAGES) {
  test(`axe: ${page}`, async ({ page: pw }) => {
    await pw.goto(page);
    await pw.waitForLoadState('networkidle');

    const results = await new AxeBuilder({ page: pw })
      .withTags(AXE_TAGS)
      .analyze();

    const slug = page.replace(/\.html$/i, '');
    const outPath = resolve(reportDir, `${slug}.json`);
    // Wrap as a single-element array so the aggregator can use the
    // same `(if type == "array" then .[0] else . end)` jq shape used
    // for the @axe-core/cli output.
    writeFileSync(outPath, JSON.stringify([results], null, 2), 'utf8');
  });
}
