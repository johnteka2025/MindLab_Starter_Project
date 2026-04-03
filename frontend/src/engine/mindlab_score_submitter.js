export async function submitScore(payload) {
    try {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), 5000);

        const response = await fetch('/score', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload),
            signal: controller.signal
        });

        clearTimeout(timeoutId);

        if (!response.ok) {
            throw new Error('HTTP ' + response.status);
        }

        const data = await response.json();
        console.log('[API OK]', data);
        return data;
    } catch (err) {
        console.error('submitScore_error:', err);
        return {
            ok: false,
            error: String(err && err.message ? err.message : err)
        };
    }
}
