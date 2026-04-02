export async function submitScore(payload) {
    try {
        const response = await fetch('http://127.0.0.1:8085/score', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload)
        });

        if (!response.ok) {
            throw new Error('HTTP ' + response.status);
        }

        const data = await response.json();
        console.log('[API OK]', data);
        return data;

    } catch (err) {
        console.error('[API ERROR]', err);
        return { ok: false, error: err.message };
    }
}
