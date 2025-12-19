// src/api.ts

export interface ApiOptions extends RequestInit {
  timeoutMs?: number;
}

// Internal low-level request helper with timeout
async function doRequest<T>(
  path: string,
  options: ApiOptions = {}
): Promise<T> {
  const { timeoutMs = 8000, headers, ...rest } = options;

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const response = await fetch(path, {
      signal: controller.signal,
      headers: {
        "Content-Type": "application/json",
        ...(headers || {}),
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

// ---------- Generic helpers ----------

/**
 * Generic API helper: api<MyType>("/path", { method: "GET" })
 */
export async function api<T = any>(
  path: string,
  options?: ApiOptions
): Promise<T> {
  return doRequest<T>(path, options);
}

/**
 * Convenience HTTP helpers:
 *   http.get<MyType>("/path")
 *   http.post<MyType>("/path", body)
 */
export const http = {
  get<T = any>(path: string, options?: ApiOptions) {
    return doRequest<T>(path, { method: "GET", ...(options || {}) });
  },

  post<T = any>(path: string, body: any, options?: ApiOptions) {
    const { headers, ...rest } = options || {};
    return doRequest<T>(path, {
      method: "POST",
      body: JSON.stringify(body),
      headers: {
        "Content-Type": "application/json",
        ...(headers || {}),
      },
      ...rest,
    });
  },
};

// ---------- Domain types ----------

export interface HealthResponse {
  status: string;
  [key: string]: unknown;
}

export interface Puzzle {
  id: string;
  question: string;
  options: string[];
  answerIndex?: number;
  [key: string]: unknown;
}

export interface Progress {
  totalPuzzles: number;
  solvedPuzzles: number;
  [key: string]: unknown;
}

// ---------- Domain-specific helpers ----------

export async function getHealth(): Promise<HealthResponse> {
  return api<HealthResponse>("/health");
}

export async function getPuzzles(): Promise<Puzzle[]> {
  return api<Puzzle[]>("/puzzles");
}

export async function getProgress(): Promise<Progress> {
  return api<Progress>("/progress");
}
