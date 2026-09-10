import { test, expect } from '@playwright/test';

test('baseline: setup, project, ticket, planning, collaboration and overview', async ({ page }, testInfo) => {
  await page.goto('/setup');
  await page.locator('input[type=email]').fill('baseline@example.invalid');
  await page.locator('input[autocomplete=name]').fill('Baseline');
  await page.locator('input[type=password]').fill('BaselineTest123!');
  await page.locator('button[type=submit]').click();
  await expect(page).toHaveURL('http://127.0.0.1:5187/');
  const token = await page.evaluate(() => localStorage.getItem('disciplaner_auth_token'));
  expect(token).toBeTruthy();
  const headers = { Authorization: 'Bearer ' + token };
  const post = async (url, data) => {
    const response = await page.request.post(url, { headers, data });
    expect(response.ok(), await response.text()).toBeTruthy();
    return response.json();
  };
  const project = await post('/api/projects', { name: 'Baseline project', key: 'BASE', description: 'Synthetic browser fixture' });
  const ticket = await post('/api/projects/' + project.id + '/tickets', {
    title: 'Baseline ticket', description: 'Work to plan', type: 2, priority: 1, storyPoints: 3
  });
  await page.goto('/projects');
  await expect(page.getByRole('heading', { name: 'Baseline project', exact: true })).toBeVisible();
  await page.locator('input[aria-label]').last().fill('BASE');
  await page.getByRole('heading', { name: 'Baseline project', exact: true }).click();
  await expect(page.getByRole('heading', { name: 'Baseline project', exact: true })).toBeVisible();
  await page.screenshot({ path: testInfo.outputPath('project-desktop.png'), fullPage: true });
  await page.goto('/tickets/' + ticket.ticketRef);
  await expect(page.getByRole('heading', { name: 'Baseline ticket', exact: true })).toBeVisible();
  await page.locator('.ticket-comment-bar textarea').fill('Baseline comment from browser');
  await page.locator('.ticket-comment-bar button.btn-primary').click();
  await expect(page.getByText('Baseline comment from browser', { exact: true })).toBeVisible();
  await page.screenshot({ path: testInfo.outputPath('ticket-desktop.png'), fullPage: true });
  const sprint = await post('/api/projects/' + project.id + '/sprints', { name: 'Baseline sprint', goal: 'Baseline goal' });
  for (const [url, data] of [
    ['/api/tickets/' + ticket.id + '/sprint', { sprintId: sprint.id }],
    ['/api/sprints/' + sprint.id + '/start', { startDate: '2026-09-11T00:00:00Z', endDate: '2026-09-25T00:00:00Z' }]
  ]) {
    const response = await page.request.put(url, { headers, data });
    expect(response.ok(), await response.text()).toBeTruthy();
  }
  await page.goto('/sprints/' + sprint.id);
  await expect(page.getByRole('heading', { name: 'Baseline sprint', exact: true })).toBeVisible();
  await expect(page.getByText('Baseline ticket', { exact: true })).toBeVisible();
  await page.goto('/calendar');
  await expect(page.locator('.app-content')).toBeVisible();
  await page.setViewportSize({ width: 390, height: 844 });
  await page.goto('/tickets/' + ticket.ticketRef);
  await expect(page.getByRole('heading', { name: 'Baseline ticket', exact: true })).toBeVisible();
  await page.screenshot({ path: testInfo.outputPath('ticket-mobile.png'), fullPage: true });
});
