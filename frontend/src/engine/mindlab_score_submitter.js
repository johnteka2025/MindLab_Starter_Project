export async function submitScore(payload) {
    const response = await fetch("${window.location.protocol}//${window.location.hostname}:8085/score", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(payload)
    })

    const data = await response.json()
    return data
}


