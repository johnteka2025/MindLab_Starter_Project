export async function submitScore(payload) {
    try {
        const response = await fetch('http://localhost:8085/score', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(payload)
        });

        const data = await response.json();
        return { ok: true, data };
    } catch (error) {
        console.error("submitScore_error:", error);
        return { ok: false, error: error.message };
    }
}
