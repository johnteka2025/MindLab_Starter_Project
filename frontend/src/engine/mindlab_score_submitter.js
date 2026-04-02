export async function submitScore(payload) {
    try {
        const response = await fetch("http://localhost:8085/score", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify(payload)
        });

        const data = await response.json();
        return data;

    } catch (err) {
        console.error("submitScore error:", err);
        return { ok: false };
    }
}
