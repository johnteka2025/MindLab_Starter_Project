export async function submitScore(payload) {
    try {
        const response = await fetch("http://localhost:8085/score", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                ageCategory: payload.ageCategory || "kids",
                level: payload.level || "K1",
                action: payload.action || "boot"
            })
        });

        if (!response.ok) {
            throw new Error("HTTP " + response.status);
        }

        const data = await response.json();
        console.log("[API OK]", data);
        return data;

    } catch (err) {
        console.error("submitScore_error:", err);
        return { ok: false, error: err.message };
    }
}
