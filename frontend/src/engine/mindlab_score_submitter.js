export async function submitScore(payload) {
    try {
        const controller = new AbortController();
        const timeout = setTimeout(() => controller.abort(), 5000);

        const response = await fetch("http://127.0.0.1:8085/score", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(payload),
            signal: controller.signal
        });

        clearTimeout(timeout);

        if (!response.ok) {
            throw new Error("HTTP " + response.status);
        }

        const data = await response.json();
        return data;

    } catch (err) {
        console.error("submitScore_error:", err);
        return { ok: false, error: err.message };
    }
}
