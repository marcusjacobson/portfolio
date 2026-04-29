import { defineConfig, devices } from '@playwright/test';

// Dedicated config for the WCAG axe-core a11y scan (issue #127).
// Kept separate from `tests/playwright.config.ts` so the visual-regression
// run is unaffected. The spec writes JSON reports to `.axe-pw-reports/`
// at the repo root; the maturity-scan workflow aggregates them.
//
// `AXE_BASE_URL` lets the workflow point at the locally booted
// http-server (matches the Option B / `@axe-core/cli` pattern). When
// running locally without a server, set it to a `file://` URL or run
// `npx http-server -p 8080 -s .` from the repo root first.
const baseURL = process.env.AXE_BASE_URL || 'http://localhost:8080/';

export default defineConfig({
  testDir: '.',
  fullyParallel: true,
  reporter: [['list']],
  use: {
    baseURL,
    trace: 'retain-on-failure',
  },
  projects: [
    { name: 'desktop', use: { viewport: { width: 1440, height: 900 } } },
  ],
});
