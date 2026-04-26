import { defineConfig, devices } from '@playwright/test';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const repoRoot = resolve(dirname(fileURLToPath(import.meta.url)), '..');

export default defineConfig({
  testDir: './visual',
  snapshotDir: './visual/__snapshots__',
  fullyParallel: true,
  reporter: [['list'], ['html', { open: 'never', outputFolder: '../playwright-report' }]],
  use: {
    baseURL: `file://${repoRoot.replace(/\\/g, '/')}/`,
    trace: 'retain-on-failure',
  },
  expect: {
    toHaveScreenshot: {
      maxDiffPixelRatio: 0.01,
      animations: 'disabled',
    },
  },
  projects: [
    { name: 'mobile',  use: { ...devices['iPhone 13'] } },
    { name: 'tablet',  use: { ...devices['iPad (gen 7)'] } },
    { name: 'desktop', use: { viewport: { width: 1440, height: 900 } } },
  ],
});
