/**
 * Daily Challenge API client
 * Talks to backend /daily endpoints.
 */
/**
 * Helper to call JSON endpoints and surface nice errors.
 */
async function fetchJson(input, init) {
    const response = await fetch(input, {
        headers: {
            "Content-Type": "application/json",
            ...(init && init.headers ? init.headers : {}),
        },
        ...init,
    });
    if (!response.ok) {
        let message = `HTTP ${response.status}`;
        try {
            const text = await response.text();
            if (text) {
                message += ` - ${text}`;
            }
        }
        catch {
            // ignore
        }
        throw new Error(message);
    }
    return (await response.json());
}
/**
 * Fetches a lightweight status object for today (no puzzle list).
 * GET /daily/status
 */
export function fetchDailyStatus() {
    return fetchJson("/daily/status", {
        method: "GET",
    });
}
/**
 * Fetches the full Daily Challenge instance for today.
 * GET /daily
 */
export function fetchDailyInstance() {
    return fetchJson("/daily", {
        method: "GET",
    });
}
/**
 * Submits an answer to a single puzzle.
 * POST /daily/answer
 */
export function submitDailyAnswer(payload) {
    return fetchJson("/daily/answer", {
        method: "POST",
        body: JSON.stringify(payload),
    });
}
