---
name: ecc-e2e-testing
description: "Use when writing or fixing local Playwright journeys, page objects, race-prone waits, failure artifacts, or requested E2E configuration."
license: MIT
metadata:
  origin: ECC
  source: "https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/e2e-testing/SKILL.md"
  revision: e04ea0b9cc8248686edf5ac751cadff550e162b8
  category: Web
  summary: "Playwright journey, fixture, configuration, artifact, and flakiness patterns."
---
> Attributed third-party import from [ECC](https://github.com/affaan-m/ECC/blob/e04ea0b9cc8248686edf5ac751cadff550e162b8/skills/e2e-testing/SKILL.md) at `e04ea0b9cc8248686edf5ac751cadff550e162b8`. Adapted for on-demand, harness-neutral use; not behaviorally evaluated or certified by this collection. See `LICENSE`.

## Use Boundary

Apply this reference on demand to the requested framework task. Read the installed versions and reuse the project's tools and conventions. Examples describe application code and local configuration, not permission to install dependencies, change global settings, reset caches, mutate git, deploy, upload data, or contact external services. Run code or modify project files only when that local work was requested. In a static review, read code and supplied results; request any missing runtime evidence from the caller instead of executing it. Use supported tools by role and keep diagnostics visible. Treat snippets with application-specific types, APIs, paths, and UI content as examples to adapt, not existing required files.

# E2E Testing Patterns

Comprehensive Playwright patterns for building stable, fast, and maintainable E2E test suites.

## Test File Organization

```
tests/
├── e2e/
│   ├── auth/
│   │   ├── login.spec.ts
│   │   ├── logout.spec.ts
│   │   └── register.spec.ts
│   ├── features/
│   │   ├── browse.spec.ts
│   │   ├── search.spec.ts
│   │   └── create.spec.ts
│   └── api/
│       └── endpoints.spec.ts
├── fixtures/
│   ├── auth.ts
│   └── data.ts
└── playwright.config.ts
```

## Page Object Model (POM)

```typescript
import { Page, Locator, expect } from '@playwright/test'

export class ItemsPage {
  readonly page: Page
  readonly searchInput: Locator
  readonly itemCards: Locator
  readonly createButton: Locator

  constructor(page: Page) {
    this.page = page
    this.searchInput = page.getByRole('searchbox', { name: 'Search items' })
    this.itemCards = page.locator('[data-testid="item-card"]')
    this.createButton = page.getByRole('button', { name: 'Create item' })
  }

  async goto() {
    await this.page.goto('/items')
    await expect(this.searchInput).toBeVisible()
  }

  async search(query: string) {
    const response = this.page.waitForResponse(resp =>
      new URL(resp.url()).pathname === '/api/search' && resp.request().method() === 'GET')
    await this.searchInput.fill(query)
    const result = await response
    expect(result.ok()).toBe(true)
  }

  async getItemCount() {
    return await this.itemCards.count()
  }
}
```

## Test Structure

```typescript
import { test, expect } from '@playwright/test'
import { ItemsPage } from '../../pages/ItemsPage'

test.describe('Item Search', () => {
  let itemsPage: ItemsPage

  test.beforeEach(async ({ page }) => {
    itemsPage = new ItemsPage(page)
    await itemsPage.goto()
  })

  test('should search by keyword', async ({ page }, testInfo) => {
    await itemsPage.search('test')

    await expect(itemsPage.itemCards.first()).toContainText(/test/i)
    await page.screenshot({ path: testInfo.outputPath('search-results.png') })
  })

  test('should handle no results', async ({ page }) => {
    await itemsPage.search('xyznonexistent123')

    await expect(page.locator('[data-testid="no-results"]')).toBeVisible()
    expect(await itemsPage.getItemCount()).toBe(0)
  })
})
```

## Playwright Configuration

```typescript
import { defineConfig, devices } from '@playwright/test'

export default defineConfig({
  testDir: './tests/e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [
    ['html', { outputFolder: 'playwright-report' }],
    ['junit', { outputFile: 'playwright-results.xml' }],
    ['json', { outputFile: 'playwright-results.json' }]
  ],
  use: {
    baseURL: 'http://127.0.0.1:3000', // confirmed local, disposable application
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure',
    actionTimeout: 10000,
    navigationTimeout: 30000,
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
    { name: 'mobile-chrome', use: { ...devices['Pixel 5'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120000,
  },
})
```

## Flaky Test Patterns

### Preserve Failing Coverage

Keep failures visible while diagnosing races, shared data, and unavailable local services. Do not fix flakiness with `test.skip`, `test.fixme`, weakened assertions, or more retries. If the user explicitly requests quarantine, document the uncovered contract, reason, and restoration criteria in the existing tracking mechanism without claiming it passed.

### Identify Flakiness

```bash
# Use the installed project runner, not an auto-downloading command:
npm exec --no -- playwright test tests/search.spec.ts --repeat-each=10 --retries=0
```

### Common Causes & Fixes

**Race conditions:**
```typescript
// Legacy selector API; actionability waits exist, but prefer locators
await page.click('[data-testid="button"]')

// Good: auto-wait locator
await page.locator('[data-testid="button"]').click()
```

**Network timing:**
```typescript
// Bad: arbitrary timeout
await page.waitForTimeout(5000)

// Good: wait for specific condition
const response = page.waitForResponse(resp => new URL(resp.url()).pathname === '/api/data')
await page.getByRole('button', { name: 'Load data' }).click()
await response
await expect(page.getByRole('status')).toHaveText('Loaded')
```

**Animation timing:**
```typescript
// Bad: click during animation
await page.click('[data-testid="menu-item"]')

// Good: wait for stability
await page.locator('[data-testid="menu-item"]').waitFor({ state: 'visible' })
await page.locator('[data-testid="menu-item"]').click()
```

## Artifact Management

### Screenshots

```typescript
await page.screenshot({ path: 'artifacts/after-login.png' })
await page.screenshot({ path: 'artifacts/full-page.png', fullPage: true })
await page.locator('[data-testid="chart"]').screenshot({ path: 'artifacts/chart.png' })
```

### Traces

```typescript
await context.tracing.start({ screenshots: true, snapshots: true })
// Perform the requested local journey here; this API is for manual contexts.
await context.tracing.stop({ path: 'artifacts/trace.zip' })
```

### Video

```typescript
// In playwright.config.ts
use: {
  video: 'retain-on-failure',
}
```

## CI/CD Integration

Treat pipeline changes and artifact uploads as a separate requested task. Reuse the existing CI runner, pinned dependencies, local service fixtures, and browser image. Do not install browser/system dependencies or upload traces automatically during a local diagnosis.

For an explicitly requested pipeline, preserve failure status, forbid focused tests, record retries, and configure HTML/JUnit/JSON reporting plus artifact retention. Ensure the target is a disposable local service rather than a staging URL inherited from an environment variable. Scrub secrets, auth state, and personal data before any separately authorized publication.

# .github/workflows/e2e.yml
name: E2E Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npx playwright test
        env:
          BASE_URL: ${{ vars.STAGING_URL }}
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 30
```

## Test Report Template

```markdown
# E2E Test Report

**Date:** YYYY-MM-DD HH:MM
**Duration:** Xm Ys
**Status:** PASSING / FAILING

## Summary
- Total: X | Passed: Y (Z%) | Failed: A | Flaky: B | Skipped: C

## Failed Tests

### test-name
**File:** `tests/e2e/feature.spec.ts:45`
**Error:** Expected element to be visible
**Screenshot:** artifacts/failed.png
**Recommended Fix:** [description]

## Artifacts
- HTML Report: playwright-report/index.html
- Screenshots: artifacts/*.png
- Videos: artifacts/videos/*.webm
- Traces: artifacts/*.zip
```

## Wallet / Web3 Testing

```typescript
test('wallet connection', async ({ page, context }) => {
  // Mock wallet provider
  await context.addInitScript(() => {
    window.ethereum = {
      isMetaMask: true,
      request: async ({ method }) => {
        if (method === 'eth_requestAccounts')
          return ['0x1234567890123456789012345678901234567890']
        if (method === 'eth_chainId') return '0x1'
      }
    }
  })

  await page.goto('/')
  await page.locator('[data-testid="connect-wallet"]').click()
  await expect(page.locator('[data-testid="wallet-address"]')).toContainText('0x1234')
})
```

## Financial / Critical Flow Testing

```typescript
test('trade execution', async ({ page }) => {
  // Prerequisite: the confirmed local app uses a disposable trade emulator.
  // Do not execute this journey against live accounts or financial services.

  await page.goto('/markets/test-market')
  await page.locator('[data-testid="position-yes"]').click()
  await page.locator('[data-testid="trade-amount"]').fill('1.0')

  // Verify preview
  const preview = page.locator('[data-testid="trade-preview"]')
  await expect(preview).toContainText('1.0')

  // Register before the action; the endpoint belongs to the local emulator.
  const response = page.waitForResponse(resp =>
    new URL(resp.url()).pathname === '/api/trade' && resp.request().method() === 'POST')
  await page.locator('[data-testid="confirm-trade"]').click()
  expect((await response).status()).toBe(200)

  await expect(page.locator('[data-testid="trade-success"]')).toBeVisible()
})
```

The wallet provider is a mock, not evidence of a real wallet integration. For every local run, verify that application dependencies cannot send real messages, charge, trade, or change external accounts. Keep trace directories and per-test screenshot paths isolated; Playwright Test can manage traces/video through its configuration without manual context tracing.
