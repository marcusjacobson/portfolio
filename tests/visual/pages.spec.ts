import { test, expect } from '@playwright/test';

const PAGES = [
  'index.html',
  'ms_security_roles.html',
  'ms_security_projects.html',
  'certification_strategy.html',
];

for (const page of PAGES) {
  test(`visual: ${page}`, async ({ page: pw }, testInfo) => {
    await pw.goto(page);
    await pw.waitForLoadState('networkidle');
    await expect(pw).toHaveScreenshot(`${page}-${testInfo.project.name}.png`, {
      fullPage: true,
    });
  });
}
