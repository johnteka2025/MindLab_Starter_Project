import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    // Only run unit tests from src/
    include: ['src/**/*.{test,spec}.{ts,tsx,js,jsx}'],

    // Hard exclusions (prevents Vitest from touching Playwright e2e specs & backups)
    exclude: [
      '**/node_modules/**',
      '**/dist/**',
      '**/build/**',
      '**/coverage/**',
      '**/backups/**',
      'tests/e2e/**',
      '**/*.e2e.*',
      '**/*.pw.*'
    ]
  }
});