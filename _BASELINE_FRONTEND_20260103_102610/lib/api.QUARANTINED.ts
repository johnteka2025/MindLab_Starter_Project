// src/lib/api.ts

export interface FetchJsonOptions extends RequestInit {
  /** Request timeout in milliseconds (default: 8000) */
  timeoutMs?: number;
  /** Additional headers to merge into the request */
  headers?: Record<string, string>;
}

/**
 * Simple JSON fetch helper with timeout support.
 */
export async function fetchJson<T = any>(
  path: string,
  opts: FetchJsonOptions = {}
): Promise<T> {
  const {
    timeoutMs = 8000,
    headers = {},
    ...rest
  } = opts;

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const response = await fetch(path, {
      signal: controller.signal,
      headers: {
        'Content-Type': 'application/json',
        ...headers,
      },
      ...rest,
    });

    if (!response.ok) {
      const text = await response.text();
      throw new Error(`HTTP ${response.status} ${response.statusText}: ${text}`);
    }

    return (await response.json()) as T;
  } finally {
    clearTimeout(timeoutId);
  }
}
