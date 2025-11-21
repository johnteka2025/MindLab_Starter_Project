// src/api.ts
// Internal low-level request helper with timeout
async function doRequest(path, options = {}) {
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
        return (await response.json());
    }
    finally {
        clearTimeout(timeoutId);
    }
}
// ---------- Generic helpers ----------
/**
 * Generic API helper: api<MyType>("/path", { method: "GET" })
 */
export async function api(path, options) {
    return doRequest(path, options);
}
/**
 * Convenience HTTP helpers:
 *   http.get<MyType>("/path")
 *   http.post<MyType>("/path", body)
 */
export const http = {
    get(path, options) {
        return doRequest(path, { method: "GET", ...(options || {}) });
    },
    post(path, body, options) {
        const { headers, ...rest } = options || {};
        return doRequest(path, {
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
// ---------- Domain-specific helpers ----------
export async function getHealth() {
    return api("/health");
}
export async function getPuzzles() {
    return api("/puzzles");
}
export async function getProgress() {
    return api("/progress");
}
