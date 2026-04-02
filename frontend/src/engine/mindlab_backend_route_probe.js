const candidates = [
    "http://127.0.0.1:8085/score",
    "http://127.0.0.1:8085/api/score",
    "http://127.0.0.1:8085/api/scores",
    "http://127.0.0.1:8085/submit-score",
    "http://127.0.0.1:8085/api/submit-score"
]

async function probe() {
    for (const url of candidates) {
        try {
            const response = await fetch('http://localhost:8085/score',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({test:1})})//url, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ test: true, score: 1 })
            })

            let body = ""
            try {
                body = await response.text()
            } catch {
                body = ""
            }

            console.log("URL:", url)
            console.log("STATUS:", response.status)
            console.log("BODY:", body)
        } catch (error) {
            console.log("URL:", url)
            console.log("STATUS:", "FETCH_ERROR")
            console.log("BODY:", error.message)
        }
    }
}

probe()


