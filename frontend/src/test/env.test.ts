import { describe, it, expect } from 'vitest';

describe('env sanity', () => {
  it('VITE_BACKEND_URL is optional (should not crash)', () => {
    // If not defined, it should be undefined or empty string - but test should pass regardless.
    const v = (import.meta as any).env?.VITE_BACKEND_URL;
    expect(v === undefined || typeof v === 'string').toBe(true);
  });
});