export async function submitScore(payload) {
    const response = await fetch("${window.location.protocol}//${window.location.hostname}:8085/score", {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify(payload)
    })

    let data = {}
try {
  data = await response.json()
} catch (e) {
  data = { error: "invalid_json" }
}
    return data
}




