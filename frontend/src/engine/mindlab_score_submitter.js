export async function submitScore(payload) {
    try {
        const response = await fetch('/score', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        });

        if (!response.ok) {
            throw new Error('HTTP ' + response.status);
        }

        const data = await response.json();

        if (!data || data.success !== true) {
            throw new Error('Invalid API response');
        }

        return data;

    } catch (err) {
        console.error('[submitScore_error]', err);
        return { ok: false, error: err.message };
    }
}
