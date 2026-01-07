// src/lib/api.ts
/**
 * Simple JSON fetch helper with timeout support.
 */
export async function fetchJson(path, opts = {}) {
    const { timeoutMs = 8000, headers = {}, ...rest } = opts;
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
        return (await response.json());
    }
    finally {
        clearTimeout(timeoutId);
    }
}
