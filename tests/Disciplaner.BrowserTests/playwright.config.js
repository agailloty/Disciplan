import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './specs', workers: 1, retries: 0, timeout: 60000,
  expect: { timeout: 15000 },
  reporter: [['list'], ['html', { open: 'never' }]],
  use: {
    baseURL: 'http://127.0.0.1:5187', browserName: 'chromium',
    channel: process.env.PLAYWRIGHT_CHANNEL || undefined,
    viewport: { width: 1440, height: 1000 }, locale: 'fr-FR',
    trace: 'retain-on-failure', screenshot: 'only-on-failure'
  },
  webServer: {
    command: 'node start-server.mjs', url: 'http://127.0.0.1:5187/api/setup/status',
    reuseExistingServer: false, timeout: 180000
  }
});
